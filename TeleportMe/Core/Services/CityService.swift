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

    /// In-memory cache of city insights keyed by cityId
    private var insightsCache: [String: CityInsights] = [:]

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

    // MARK: - Sorted Cities by Category

    /// Fetches cities sorted by a specific score category (descending).
    /// Returns an array of (City, sortScore) tuples.
    func citiesSortedByCategory(_ category: String, limit: Int = 50) async -> [(City, Double)] {
        do {
            struct SortedCity: Codable {
                let id: String
                let name: String
                let fullName: String
                let country: String
                let continent: String
                let latitude: Double
                let longitude: Double
                let population: Int?
                let teleportCityScore: Double?
                let summary: String?
                let imageUrl: String?
                let createdAt: Date?
                let updatedAt: Date?
                let sortScore: Double

                enum CodingKeys: String, CodingKey {
                    case id, name, country, continent, latitude, longitude, population, summary
                    case fullName = "full_name"
                    case teleportCityScore = "teleport_city_score"
                    case imageUrl = "image_url"
                    case createdAt = "created_at"
                    case updatedAt = "updated_at"
                    case sortScore = "sort_score"
                }
            }

            let results: [SortedCity] = try await withTimeout(seconds: 15) {
                try await self.supabase
                    .rpc("cities_sorted_by_category", params: [
                        "sort_category": category,
                        "sort_limit": String(limit)
                    ])
                    .execute()
                    .value
            }

            return results.map { sc in
                let city = City(
                    id: sc.id, name: sc.name, fullName: sc.fullName,
                    country: sc.country, continent: sc.continent,
                    latitude: sc.latitude, longitude: sc.longitude,
                    population: sc.population,
                    teleportCityScore: sc.teleportCityScore,
                    summary: sc.summary, imageUrl: sc.imageUrl,
                    createdAt: sc.createdAt, updatedAt: sc.updatedAt
                )
                return (city, sc.sortScore)
            }
        } catch {
            print("Failed to fetch sorted cities for \(category): \(error)")
            return []
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

    // MARK: - Fetch All Scores (bulk)

    /// Fetches scores for all cities in one batch and populates the in-memory `scoreCache`.
    /// Called once at startup after `fetchAllCities()`.
    func fetchAllScores() async {
        // Return if we already have a well-populated cache
        guard scoreCache.count < allCities.count / 2 else { return }

        // Try loading from disk cache first
        if let cached = cache.load([String: [String: Double]].self, for: .cityScores, ttl: scoresTTL) {
            scoreCache = cached.data
            if !cached.isStale { return }
        }

        // Fetch all scores from the DB
        do {
            let allScores: [CityScore] = try await withTimeout(seconds: 30) {
                try await self.supabase
                    .from("city_scores")
                    .select()
                    .execute()
                    .value
            }

            // Group by city_id
            var grouped: [String: [String: Double]] = [:]
            for score in allScores {
                grouped[score.cityId, default: [:]][score.category] = score.score
            }
            scoreCache = grouped
            cache.save(scoreCache, for: .cityScores)
        } catch {
            print("Failed to fetch all scores: \(error)")
        }
    }

    // MARK: - City Insights

    /// Fetches "Known For" and "Concerns" for a city.
    /// Calls the `city-insights` edge function, which caches results server-side for 30 days.
    /// Results are also cached in memory on the client.
    func getCityInsights(cityId: String) async -> CityInsights? {
        // Check in-memory cache
        if let cached = insightsCache[cityId] {
            return cached
        }

        // Call edge function
        do {
            let response: CityInsights = try await withTimeout(seconds: 15) {
                try await self.supabase.functions.invoke(
                    "city-insights",
                    options: .init(body: ["city_id": cityId])
                )
            }
            insightsCache[cityId] = response
            return response
        } catch {
            print("Failed to fetch city insights for \(cityId): \(error)")
            return nil
        }
    }

    // MARK: - Similar Cities

    /// The 8 primary score categories used for similarity comparison.
    private static let similarityCategories = [
        "Cost of Living", "Environmental Quality", "Leisure & Culture",
        "Economy", "Safety", "Commute", "Healthcare", "Outdoors"
    ]

    /// A city similar to a reference city, with a human-readable comparison tag.
    struct SimilarCity {
        let city: City
        let distance: Double
        let comparisonTag: String
    }

    /// Finds the most similar cities to `cityId` using Euclidean distance across score categories.
    /// Returns up to `limit` results, sorted by similarity (smallest distance first).
    func similarCities(to cityId: String, limit: Int = 8) -> [SimilarCity] {
        guard let targetScores = scoreCache[cityId] else { return [] }

        var results: [(city: City, distance: Double, tag: String)] = []

        for otherCity in allCities where otherCity.id != cityId {
            guard let otherScores = scoreCache[otherCity.id] else { continue }

            // Compute Euclidean distance across shared categories
            var sumSquared = 0.0
            var categoryCount = 0

            for category in Self.similarityCategories {
                guard let targetVal = targetScores[category],
                      let otherVal = otherScores[category] else { continue }
                let diff = targetVal - otherVal
                sumSquared += diff * diff
                categoryCount += 1
            }

            guard categoryCount >= 4 else { continue } // Need enough categories for meaningful comparison

            let distance = (sumSquared / Double(categoryCount)).squareRoot()
            let tag = Self.comparisonTag(
                targetCityId: cityId,
                targetScores: targetScores,
                otherCity: otherCity,
                otherScores: otherScores
            )

            results.append((otherCity, distance, tag))
        }

        // Sort by distance (most similar first)
        results.sort { $0.distance < $1.distance }

        return results.prefix(limit).map {
            SimilarCity(city: $0.city, distance: $0.distance, comparisonTag: $0.tag)
        }
    }

    /// Generates a human-readable comparison tag like "More affordable" or "Better nightlife".
    /// Finds the category with the largest positive delta (where the other city beats the target).
    private static func comparisonTag(
        targetCityId: String,
        targetScores: [String: Double],
        otherCity: City,
        otherScores: [String: Double]
    ) -> String {
        var bestCategory: String?
        var bestDelta = 0.0

        for category in similarityCategories {
            guard let targetVal = targetScores[category],
                  let otherVal = otherScores[category] else { continue }
            let delta = otherVal - targetVal
            if delta > bestDelta {
                bestDelta = delta
                bestCategory = category
            }
        }

        guard let category = bestCategory, bestDelta > 0.3 else {
            return "Very similar"
        }

        switch category {
        case "Cost of Living": return "More affordable"
        case "Environmental Quality": return "Better climate"
        case "Leisure & Culture": return "More culture"
        case "Economy": return "Stronger job market"
        case "Safety": return "Safer"
        case "Commute": return "Better transit"
        case "Healthcare": return "Better healthcare"
        case "Outdoors": return "More outdoors"
        default: return "Very similar"
        }
    }
}
