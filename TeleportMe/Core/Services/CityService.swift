import Foundation
import Supabase

// MARK: - City Service

@Observable
final class CityService {
    private let supabase = SupabaseManager.shared.client

    var allCities: [City] = []
    var isLoading = false

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
        defer { isLoading = false }

        do {
            let cities: [City] = try await supabase
                .from("cities")
                .select()
                .order("name")
                .execute()
                .value
            allCities = cities
        } catch {
            print("Failed to fetch cities: \(error)")
        }
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
            let results: [City] = try await supabase
                .rpc("search_cities", params: ["search_term": query])
                .execute()
                .value
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

        do {
            let scores: [CityScore] = try await supabase
                .from("city_scores")
                .select()
                .eq("city_id", value: cityId)
                .execute()
                .value

            let scoreDict = Dictionary(
                uniqueKeysWithValues: scores.map { ($0.category, $0.score) }
            )
            return CityWithScores(city: city, scores: scoreDict)
        } catch {
            print("Failed to fetch scores for \(cityId): \(error)")
            return nil
        }
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
