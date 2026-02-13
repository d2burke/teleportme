import Foundation
import Supabase

// MARK: - City Service

@Observable
final class CityService {
    private let supabase = SupabaseManager.shared.client
    private let cache = CacheManager.shared

    private let citiesTTL: TimeInterval = 24 * 60 * 60   // 24 hours
    private let scoresTTL: TimeInterval = 24 * 60 * 60   // 24 hours

    var allCities: [City] = []
    var isLoading = false
    var loadError: String?

    /// In-memory cache of fetched scores keyed by cityId
    private var scoreCache: [String: [String: Double]] = [:]

    /// Trending cities shown on the search screen
    var trendingCityIds: [String] {
        ["lisbon", "austin", "tokyo", "berlin", "bali"]
    }

    var trendingCities: [City] {
        trendingCityIds.compactMap { id in allCities.first { $0.id == id } }
    }

    // MARK: - Fetch All Cities

    func fetchAllCities() async {
        guard allCities.isEmpty else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        // Step 1: Load from cache immediately
        if let cached = cache.load([City].self, for: .cities, ttl: citiesTTL) {
            allCities = cached.data
            if !cached.isStale { return }  // Fresh cache — skip network
        }

        // Step 2: Fetch from network
        do {
            let cities: [City] = try await withTimeout(seconds: 15) {
                try await self.supabase
                    .from("cities")
                    .select()
                    .order("name")
                    .execute()
                    .value
            }
            allCities = cities
            cache.save(cities, for: .cities)
        } catch {
            // Only show error if we have no cached data
            if allCities.isEmpty {
                loadError = error.localizedDescription
            }
            print("Failed to fetch cities: \(error)")
        }
    }

    /// Clears the error and retries fetching cities.
    func retryFetch() async {
        allCities = []
        loadError = nil
        cache.remove(for: .cities)
        await fetchAllCities()
    }

    // MARK: - Search Cities

    func searchCities(query: String) async -> [City] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }

        // First try local search (instant)
        let localResults = allCities.filter { city in
            city.name.localizedCaseInsensitiveContains(query) ||
            city.fullName.localizedCaseInsensitiveContains(query) ||
            city.country.localizedCaseInsensitiveContains(query)
        }

        if !localResults.isEmpty {
            return localResults
        }

        // Fall back to server search (fuzzy)
        do {
            let results: [City] = try await withTimeout(seconds: 10) {
                try await self.supabase
                    .rpc("search_cities", params: ["search_term": query])
                    .execute()
                    .value
            }
            return results
        } catch {
            print("Search failed: \(error)")
            return []
        }
    }

    // MARK: - Get City with Scores

    func getCityWithScores(cityId: String) async -> CityWithScores? {
        guard let city = allCities.first(where: { $0.id == cityId }) else {
            return nil
        }

        // Check in-memory score cache
        if let scores = scoreCache[cityId] {
            return CityWithScores(city: city, scores: scores)
        }

        // Check disk cache
        if scoreCache.isEmpty,
           let cached = cache.load([String: [String: Double]].self, for: .cityScores, ttl: scoresTTL) {
            scoreCache = cached.data
            if let scores = scoreCache[cityId] {
                return CityWithScores(city: city, scores: scores)
            }
        }

        // Fetch from network
        do {
            let scores: [CityScore] = try await withTimeout(seconds: 10) {
                try await self.supabase
                    .from("city_scores")
                    .select()
                    .eq("city_id", value: cityId)
                    .execute()
                    .value
            }

            let scoreDict = Dictionary(
                uniqueKeysWithValues: scores.map { ($0.category, $0.score) }
            )
            scoreCache[cityId] = scoreDict
            cache.save(scoreCache, for: .cityScores)
            return CityWithScores(city: city, scores: scoreDict)
        } catch {
            print("Failed to fetch scores for \(cityId): \(error)")
            return nil
        }
    }

    // MARK: - Cached Score Lookup

    /// Returns a cached score for a given city and category, or nil if not yet fetched.
    /// Used by CityDetailView for pivot-city comparisons without triggering network calls.
    func cachedScore(cityId: String, category: String) -> Double? {
        scoreCache[cityId]?[category]
    }

    // MARK: - Get Multiple Cities with Scores

    func getCitiesWithScores(cityIds: [String]) async -> [CityWithScores] {
        var results: [CityWithScores] = []
        for id in cityIds {
            if let cityWithScores = await getCityWithScores(cityId: id) {
                results.append(cityWithScores)
            }
        }
        return results
    }
}
