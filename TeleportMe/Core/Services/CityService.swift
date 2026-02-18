import Foundation
import Supabase

// MARK: - City Vibe Tag Join (for Supabase select with join)

/// Decodes the joined query: `city_vibe_tags.select("city_id, vibe_tags(name)")`
private struct CityVibeTagJoin: Decodable {
    let cityId: String
    let vibeTags: VibeTagName

    struct VibeTagName: Decodable {
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case cityId = "city_id"
        case vibeTags = "vibe_tags"
    }
}

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

    /// In-memory cache of vibe tag names per city (e.g. ["Beach Life", "Outdoorsy"])
    private(set) var vibeTagCache: [String: Set<String>] = [:]

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

        // Fetch all scores and vibe tags from the DB in parallel
        do {
            async let scoresFetch: [CityScore] = withTimeout(seconds: 30) {
                try await self.supabase
                    .from("city_scores")
                    .select()
                    .execute()
                    .value
            }

            async let vibeTagsFetch: [CityVibeTagJoin] = withTimeout(seconds: 30) {
                try await self.supabase
                    .from("city_vibe_tags")
                    .select("city_id, vibe_tags(name)")
                    .execute()
                    .value
            }

            let (allScores, allVibeTags) = try await (scoresFetch, vibeTagsFetch)

            // Group scores by city_id
            var grouped: [String: [String: Double]] = [:]
            for score in allScores {
                grouped[score.cityId, default: [:]][score.category] = score.score
            }
            scoreCache = grouped
            cache.save(scoreCache, for: .cityScores)

            // Group vibe tags by city_id
            var vibeGroups: [String: Set<String>] = [:]
            for row in allVibeTags {
                vibeGroups[row.cityId, default: []].insert(row.vibeTags.name)
            }
            vibeTagCache = vibeGroups
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

        // Call edge function — try SDK first, fall back to direct URLSession on 401
        do {
            let response: CityInsights
            do {
                response = try await withTimeout(seconds: 15) {
                    try await self.supabase.functions.invoke(
                        "city-insights",
                        options: .init(body: ["city_id": cityId])
                    )
                }
            } catch let fnError as FunctionsError {
                // The SDK's fetchWithAuth overwrites our Authorization header with the
                // (possibly expired) session token. Bypass the SDK entirely on 401.
                if case .httpError(code: 401, _) = fnError {
                    print("city-insights 401 — retrying via direct URLSession")
                    response = try await SupabaseManager.invokeEdgeFunctionDirect(
                        "city-insights",
                        body: ["city_id": cityId]
                    )
                } else {
                    throw fnError
                }
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

    /// Finds the most similar cities using a blend of category score distance and vibe tag overlap.
    /// - Category distance (40%): Euclidean distance across 8 score categories, normalized 0-1
    /// - Vibe tag similarity (60%): Jaccard index of shared vibe tag names
    /// This ensures cities like Virginia Beach ↔ San Diego rank as similar (shared Beach Life,
    /// Outdoorsy, Family Friendly) despite differing Cost of Living scores.
    func similarCities(to cityId: String, limit: Int = 8) -> [SimilarCity] {
        guard let targetScores = scoreCache[cityId] else { return [] }
        let targetTags = vibeTagCache[cityId] ?? []

        var results: [(city: City, similarity: Double, tag: String)] = []

        // Pre-compute max possible distance for normalization
        // Max distance = sqrt(8 * 10^2) ≈ 28.3 (all categories differ by 10)
        let maxDistance = (Double(Self.similarityCategories.count) * 100.0).squareRoot()

        for otherCity in allCities where otherCity.id != cityId {
            guard let otherScores = scoreCache[otherCity.id] else { continue }
            let otherTags = vibeTagCache[otherCity.id] ?? []

            // Category distance (Euclidean, normalized to 0-1 where 0 = identical)
            var sumSquared = 0.0
            var categoryCount = 0

            for category in Self.similarityCategories {
                guard let targetVal = targetScores[category],
                      let otherVal = otherScores[category] else { continue }
                let diff = targetVal - otherVal
                sumSquared += diff * diff
                categoryCount += 1
            }

            guard categoryCount >= 4 else { continue }

            let distance = (sumSquared / Double(categoryCount)).squareRoot()
            let normalizedDistance = min(distance / maxDistance, 1.0)
            let categoryScore = 1.0 - normalizedDistance  // 1 = identical, 0 = maximally different

            // Vibe tag Jaccard similarity: |intersection| / |union|
            let vibeScore: Double
            if targetTags.isEmpty && otherTags.isEmpty {
                vibeScore = 0.5  // No data → neutral
            } else if targetTags.isEmpty || otherTags.isEmpty {
                vibeScore = 0.0  // One has tags, other doesn't → low similarity
            } else {
                let intersection = targetTags.intersection(otherTags).count
                let union = targetTags.union(otherTags).count
                vibeScore = Double(intersection) / Double(union)
            }

            // Blended similarity: 40% category + 60% vibe tags
            let similarity = categoryScore * 0.4 + vibeScore * 0.6

            let tag = Self.comparisonTag(
                targetScores: targetScores,
                otherScores: otherScores,
                targetTags: targetTags,
                otherTags: otherTags
            )

            results.append((otherCity, similarity, tag))
        }

        // Sort by similarity (highest first)
        results.sort { $0.similarity > $1.similarity }

        return results.prefix(limit).map {
            SimilarCity(city: $0.city, distance: 1.0 - $0.similarity, comparisonTag: $0.tag)
        }
    }

    /// Generates a human-readable comparison tag.
    /// Prioritizes shared vibe tags (e.g., "Also Beach Life"), then falls back to
    /// category deltas (e.g., "More affordable").
    private static func comparisonTag(
        targetScores: [String: Double],
        otherScores: [String: Double],
        targetTags: Set<String>,
        otherTags: Set<String>
    ) -> String {
        // First, check for distinctive shared vibe tags
        let sharedTags = targetTags.intersection(otherTags)
        if !sharedTags.isEmpty {
            // Prioritize the most distinctive/interesting shared tags
            let tagPriority = [
                "Beach Life", "Outdoorsy", "Foodie", "Nightlife", "Arts & Music",
                "Startup Hub", "Bohemian", "Coffee Culture", "Digital Nomad",
                "LGBTQ+ Friendly", "Eco-Conscious", "Historic", "Cosmopolitan",
                "Family Friendly", "Luxury", "Affordable", "Student Friendly",
                "Fast-Paced", "Quiet & Peaceful", "Walkable"
            ]
            for tag in tagPriority {
                if sharedTags.contains(tag) {
                    return "Also \(tag)"
                }
            }
        }

        // Fallback: find the category where the other city beats the target most
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
