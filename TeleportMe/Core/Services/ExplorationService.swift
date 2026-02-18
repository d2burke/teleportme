import Foundation
import Supabase

// MARK: - Exploration Service

@Observable
final class ExplorationService {
    private let supabase = SupabaseManager.shared.client
    private let cache = CacheManager.shared

    private let explorationsTTL: TimeInterval = 60 * 60  // 1 hour

    var explorations: [Exploration] = []
    var isGenerating = false
    var isLoading = false
    var error: String?

    // MARK: - Generate Exploration (calls Edge Function)

    /// Creates a new exploration by calling the generate-report edge function
    /// with the new optional-city, titled format.
    func generateExploration(
        title: String,
        startType: StartType = .cityILove,
        baselineCityId: String?,
        preferences: UserPreferences,
        vibeTags: [String]? = nil,
        userVibeTags: [String]? = nil,
        compassVibes: [String: Double]? = nil,
        compassConstraints: TripConstraints? = nil,
        userId: String? = nil
    ) async throws -> GenerateReportResponse {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            let body = ExplorationRequest(
                currentCityId: baselineCityId,
                startType: startType.rawValue,
                title: title,
                preferences: .init(
                    cost: preferences.costPreference,
                    climate: preferences.climatePreference,
                    culture: preferences.culturePreference,
                    jobMarket: preferences.jobMarketPreference,
                    safety: preferences.safetyPreference,
                    commute: preferences.commutePreference,
                    healthcare: preferences.healthcarePreference
                ),
                vibeTags: vibeTags,
                userVibeTags: userVibeTags,
                compassVibes: compassVibes,
                compassConstraints: compassConstraints
            )

            let response: GenerateReportResponse
            do {
                response = try await withTimeout(seconds: 30) {
                    try await self.supabase.functions
                        .invoke(
                            "generate-report",
                            options: .init(body: body)
                        )
                }
            } catch let fnError as FunctionsError {
                // The SDK's fetchWithAuth overwrites our Authorization header with the
                // (possibly expired) session token. Bypass the SDK entirely on 401.
                if case .httpError(code: 401, _) = fnError {
                    print("generate-report 401 — retrying via direct URLSession")
                    response = try await SupabaseManager.invokeEdgeFunctionDirect(
                        "generate-report",
                        body: body
                    )
                } else {
                    throw fnError
                }
            }

            // Write-through cache for explorations list
            if let userId {
                await refreshExplorations(userId: userId)
            }

            return response
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Load Explorations

    /// Loads all explorations for a user with cache-then-network strategy.
    func loadExplorations(userId: String) async {
        isLoading = true
        defer { isLoading = false }

        // Step 1: Load from cache immediately
        if let cached = cache.load(
            [Exploration].self,
            for: .explorations(userId: userId),
            ttl: explorationsTTL
        ) {
            explorations = cached.data

            // If fresh, return immediately without network call
            if !cached.isStale {
                self.error = nil
                return
            }

            // Stale: try network, fall back to cached on failure
            do {
                let fresh = try await fetchExplorationsFromNetwork(userId: userId)
                explorations = fresh
                self.error = nil
            } catch {
                self.error = error.localizedDescription
                print("Failed to refresh explorations, using cache: \(error)")
            }
            return
        }

        // Step 2: No cache — must fetch from network
        do {
            let fresh = try await fetchExplorationsFromNetwork(userId: userId)
            explorations = fresh
            self.error = nil
        } catch {
            self.error = error.localizedDescription
            print("Failed to load explorations: \(error)")
        }
    }

    // MARK: - Rename Exploration

    func renameExploration(id: String, newTitle: String, userId: String) async {
        // Optimistic update
        if let index = explorations.firstIndex(where: { $0.id == id }) {
            explorations[index].title = newTitle
            explorations[index].updatedAt = Date()
            cache.save(explorations, for: .explorations(userId: userId))
        }

        do {
            try await supabase
                .from("explorations")
                .update(["title": newTitle, "updated_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: id)
                .execute()
        } catch {
            print("Failed to rename exploration \(id): \(error)")
            // Revert on failure
            await refreshExplorations(userId: userId)
        }
    }

    // MARK: - Delete Exploration

    func deleteExploration(id: String, userId: String) async {
        // Optimistic removal
        let backup = explorations
        explorations.removeAll { $0.id == id }
        cache.save(explorations, for: .explorations(userId: userId))

        do {
            try await supabase
                .from("explorations")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("Failed to delete exploration \(id): \(error)")
            // Revert on failure
            explorations = backup
            cache.save(explorations, for: .explorations(userId: userId))
        }
    }

    // MARK: - Restore from Cache

    /// Restores explorations from disk cache (called on app relaunch).
    func restoreFromCache(userId: String) {
        if let cached = cache.load(
            [Exploration].self,
            for: .explorations(userId: userId)
        ) {
            explorations = cached.data
        }
    }

    // MARK: - Vibe Tags

    /// Fetches all available vibe tags from Supabase.
    func fetchVibeTags() async throws -> [VibeTag] {
        try await withTimeout(seconds: 10) {
            try await self.supabase
                .from("vibe_tags")
                .select()
                .order("category")
                .order("name")
                .execute()
                .value
        }
    }

    // MARK: - Private Helpers

    private func fetchExplorationsFromNetwork(userId: String) async throws -> [Exploration] {
        let explorations: [Exploration] = try await withTimeout(seconds: 10) {
            try await self.supabase
                .from("explorations")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
        }
        cache.save(explorations, for: .explorations(userId: userId))
        return explorations
    }

    /// Force-refreshes explorations from network after a mutation.
    private func refreshExplorations(userId: String) async {
        do {
            let fresh = try await fetchExplorationsFromNetwork(userId: userId)
            explorations = fresh
        } catch {
            print("Failed to refresh explorations after mutation: \(error)")
        }
    }

    // MARK: - Heading Persistence

    /// Saves signal weights to user_preferences for heading persistence.
    func saveSignalWeights(_ weights: [String: Double], userId: String) async throws {
        try await supabase
            .from("user_preferences")
            .update(["signal_weights": weights])
            .eq("user_id", value: userId)
            .execute()
    }

    /// Fetches saved signal weights from user_preferences.
    func fetchSignalWeights(userId: String) async throws -> [String: Double]? {
        struct Row: Decodable {
            let signalWeights: [String: Double]?
            enum CodingKeys: String, CodingKey {
                case signalWeights = "signal_weights"
            }
        }

        let result: Row? = try await supabase
            .from("user_preferences")
            .select("signal_weights")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value

        return result?.signalWeights
    }
}

// MARK: - Exploration Request Body (for edge function)

private struct ExplorationRequest: Encodable {
    let currentCityId: String?
    let startType: String
    let title: String?
    let preferences: Preferences
    let vibeTags: [String]?
    let userVibeTags: [String]?
    let compassVibes: [String: Double]?
    let compassConstraints: TripConstraints?

    struct Preferences: Encodable {
        let cost: Double
        let climate: Double
        let culture: Double
        let jobMarket: Double
        let safety: Double
        let commute: Double
        let healthcare: Double

        enum CodingKeys: String, CodingKey {
            case cost, climate, culture, safety, commute, healthcare
            case jobMarket = "job_market"
        }
    }

    enum CodingKeys: String, CodingKey {
        case preferences
        case currentCityId = "current_city_id"
        case startType = "start_type"
        case title
        case vibeTags = "vibe_tags"
        case userVibeTags = "user_vibe_tags"
        case compassVibes = "compass_vibes"
        case compassConstraints = "compass_constraints"
    }
}
