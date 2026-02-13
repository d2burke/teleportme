import Foundation

// MARK: - Cache Key

enum CacheKey {
    // Global (shared across accounts)
    case cities
    case cityScores

    // Per-user
    case savedCities(userId: String)
    case currentReport(userId: String)
    case pastReports(userId: String)
    case preferences(userId: String)
    case selectedCity(userId: String)
    case explorations(userId: String)

    // Global analytics queue (persisted on flush failure / background)
    case analyticsQueue

    var filename: String {
        switch self {
        case .cities: return "cities.json"
        case .cityScores: return "city_scores.json"
        case .savedCities: return "saved_cities.json"
        case .currentReport: return "current_report.json"
        case .pastReports: return "past_reports.json"
        case .preferences: return "preferences.json"
        case .selectedCity: return "selected_city.json"
        case .explorations: return "explorations.json"
        case .analyticsQueue: return "analytics_queue.json"
        }
    }

    var isGlobal: Bool {
        switch self {
        case .cities, .cityScores, .analyticsQueue: return true
        default: return false
        }
    }

    var userId: String? {
        switch self {
        case .savedCities(let id), .currentReport(let id),
             .pastReports(let id), .preferences(let id),
             .selectedCity(let id), .explorations(let id):
            return id
        case .cities, .cityScores, .analyticsQueue:
            return nil
        }
    }
}

// MARK: - Cached Data Wrapper

struct CachedData<T: Codable>: Codable {
    let data: T
    let cachedAt: Date

    var age: TimeInterval {
        Date().timeIntervalSince(cachedAt)
    }

    func isStale(ttl: TimeInterval) -> Bool {
        age > ttl
    }
}

// MARK: - Cache Manager

final class CacheManager {
    static let shared = CacheManager()

    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Directory Setup

    private func cacheDirectory(for key: CacheKey) -> URL {
        let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let base = appSupport
            .appendingPathComponent("TeleportMe", isDirectory: true)
            .appendingPathComponent("Cache", isDirectory: true)

        if key.isGlobal {
            return base.appendingPathComponent("global", isDirectory: true)
        } else {
            return base.appendingPathComponent(
                key.userId ?? "unknown", isDirectory: true
            )
        }
    }

    private func fileURL(for key: CacheKey) -> URL {
        cacheDirectory(for: key)
            .appendingPathComponent(key.filename)
    }

    // MARK: - Save

    /// Writes data to the cache file atomically.
    /// This is synchronous — data sizes are tiny (<200KB total) so main-thread is fine.
    func save<T: Codable>(_ data: T, for key: CacheKey) {
        let wrapped = CachedData(data: data, cachedAt: Date())
        do {
            let dir = cacheDirectory(for: key)
            try fileManager.createDirectory(
                at: dir, withIntermediateDirectories: true
            )
            let jsonData = try encoder.encode(wrapped)
            try jsonData.write(to: fileURL(for: key), options: .atomic)
        } catch {
            print("[CacheManager] Save failed for \(key.filename): \(error)")
        }
    }

    // MARK: - Load

    /// Loads data from cache with TTL-based staleness check.
    /// Returns `nil` if the cache file doesn't exist or is corrupt.
    /// Corrupt files are automatically deleted.
    func load<T: Codable>(
        _ type: T.Type,
        for key: CacheKey,
        ttl: TimeInterval = .infinity
    ) -> (data: T, isStale: Bool)? {
        let url = fileURL(for: key)
        guard let jsonData = try? Data(contentsOf: url) else {
            return nil
        }

        do {
            let wrapped = try decoder.decode(
                CachedData<T>.self, from: jsonData
            )
            return (wrapped.data, wrapped.isStale(ttl: ttl))
        } catch {
            // Corrupt cache — delete it
            print("[CacheManager] Corrupt cache for \(key.filename), deleting: \(error)")
            try? fileManager.removeItem(at: url)
            return nil
        }
    }

    // MARK: - Delete

    /// Removes a single cache file.
    func remove(for key: CacheKey) {
        try? fileManager.removeItem(at: fileURL(for: key))
    }

    // MARK: - Clear User Cache (on sign-out)

    /// Deletes all cache files for a specific user.
    func clearUserCache(userId: String) {
        let dir = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
            .appendingPathComponent("TeleportMe/Cache/\(userId)")
        try? fileManager.removeItem(at: dir)
    }

    // MARK: - Clear All

    /// Deletes the entire cache directory (all users + global).
    func clearAll() {
        let dir = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
            .appendingPathComponent("TeleportMe/Cache")
        try? fileManager.removeItem(at: dir)
    }
}
