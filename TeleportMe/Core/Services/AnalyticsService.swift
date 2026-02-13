import Foundation
import Supabase

// MARK: - Analytics Event

struct AnalyticsEvent: Codable {
    let name: String
    let screen: String
    let properties: [String: String]
    let timestamp: Date
    let sessionId: String
    let userId: String?
    let appVersion: String
    let buildType: String

    enum CodingKeys: String, CodingKey {
        case name = "event_name"
        case screen
        case properties
        case timestamp = "created_at"
        case sessionId = "session_id"
        case userId = "user_id"
        case appVersion = "app_version"
        case buildType = "build_type"
    }
}

// MARK: - Analytics Service

/// Lightweight, privacy-first analytics service. All tracking is fire-and-forget.
/// Events are batched in memory and flushed to Supabase periodically or on background transition.
/// On flush failure, events persist to disk via CacheManager and drain on next launch.
@Observable
final class AnalyticsService {
    static let shared = AnalyticsService()

    // MARK: - Public State

    /// Set when user authenticates, cleared on sign-out.
    var userId: String? {
        didSet {
            // Backfill userId on queued events that were tracked before auth
            if let userId, userId != oldValue {
                backfillUserId(userId)
            }
        }
    }

    // MARK: - Private State

    private let sessionId = UUID().uuidString
    private var eventQueue: [AnalyticsEvent] = []
    private var flushTimer: Timer?
    private let flushThreshold = 10
    private let flushInterval: TimeInterval = 30

    private let supabase = SupabaseManager.shared.client
    private let cache = CacheManager.shared

    private let appVersion: String
    private let buildType: String

    // MARK: - Init

    private init() {
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

        #if DEBUG
        buildType = "debug"
        #else
        buildType = "release"
        #endif

        startFlushTimer()
    }

    // MARK: - Convenience Tracking Methods

    /// Track any event with a name, screen, and optional properties.
    func track(_ name: String, screen: String, properties: [String: String] = [:]) {
        let event = AnalyticsEvent(
            name: name,
            screen: screen,
            properties: properties,
            timestamp: Date(),
            sessionId: sessionId,
            userId: userId,
            appVersion: appVersion,
            buildType: buildType
        )
        enqueue(event)
    }

    /// Track a screen view. Call in `.onAppear` or `.task`.
    func trackScreenView(_ screen: String, properties: [String: String] = [:]) {
        track("screen_viewed", screen: screen, properties: properties)
    }

    /// Track a screen exit with duration and exit type. Call in `.onDisappear`.
    func trackScreenExit(_ screen: String, durationMs: Int, exitType: String, properties: [String: String] = [:]) {
        var props = properties
        props["duration_ms"] = String(durationMs)
        props["exit_type"] = exitType
        track("screen_exited", screen: screen, properties: props)
    }

    /// Track a button tap.
    func trackButtonTap(_ button: String, screen: String, properties: [String: String] = [:]) {
        var props = properties
        props["button"] = button
        track("button_tapped", screen: screen, properties: props)
    }

    /// Track a slider value change.
    func trackSliderChange(metricId: String, screen: String, fromValue: Double, toValue: Double) {
        track("slider_changed", screen: screen, properties: [
            "metric_id": metricId,
            "from_value": String(format: "%.2f", fromValue),
            "to_value": String(format: "%.2f", toValue)
        ])
    }

    // MARK: - Queue Management

    private func enqueue(_ event: AnalyticsEvent) {
        eventQueue.append(event)

        if eventQueue.count >= flushThreshold {
            Task { await flush() }
        }
    }

    /// Backfill userId on events that were queued before authentication completed.
    private func backfillUserId(_ newUserId: String) {
        eventQueue = eventQueue.map { event in
            guard event.userId == nil else { return event }
            return AnalyticsEvent(
                name: event.name,
                screen: event.screen,
                properties: event.properties,
                timestamp: event.timestamp,
                sessionId: event.sessionId,
                userId: newUserId,
                appVersion: event.appVersion,
                buildType: event.buildType
            )
        }
    }

    // MARK: - Flush

    /// Flush all queued events to Supabase. On failure, persist to disk.
    func flush() async {
        guard !eventQueue.isEmpty else { return }

        let batch = eventQueue
        eventQueue.removeAll()

        do {
            try await supabase
                .from("analytics_events")
                .insert(batch)
                .execute()
        } catch {
            print("[Analytics] Flush failed (\(batch.count) events): \(error.localizedDescription)")
            // Re-queue failed events and persist
            eventQueue.insert(contentsOf: batch, at: 0)
            persistToDisk()
        }
    }

    // MARK: - Disk Persistence

    /// Persist queued events to disk for offline resilience.
    func persistToDisk() {
        guard !eventQueue.isEmpty else { return }
        let events = eventQueue
        eventQueue.removeAll()

        // Load any existing persisted events and merge
        var allEvents = loadPersistedEvents()
        allEvents.append(contentsOf: events)

        cache.save(allEvents, for: .analyticsQueue)
    }

    /// Drain any events persisted from a previous session.
    func drainPersistedEvents() {
        let persisted = loadPersistedEvents()
        guard !persisted.isEmpty else { return }

        // Clear the disk cache immediately
        cache.remove(for: .analyticsQueue)

        // Enqueue them for the next flush
        eventQueue.insert(contentsOf: persisted, at: 0)

        print("[Analytics] Drained \(persisted.count) persisted events")

        // Trigger a flush
        Task { await flush() }
    }

    private func loadPersistedEvents() -> [AnalyticsEvent] {
        guard let cached = cache.load([AnalyticsEvent].self, for: .analyticsQueue) else {
            return []
        }
        return cached.data
    }

    // MARK: - Flush Timer

    private func startFlushTimer() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.flush() }
        }
    }

    /// Call when the app goes to the background to flush + persist.
    func handleBackgroundTransition() {
        Task {
            await flush()
        }
        // Also persist anything that didn't flush
        persistToDisk()
    }

    deinit {
        flushTimer?.invalidate()
    }
}
