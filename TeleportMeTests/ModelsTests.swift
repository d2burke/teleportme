import Testing
import Foundation
@testable import TeleportMe

// MARK: - Models Tests

struct ModelsTests {

    // MARK: - Helpers

    private func sampleCity(
        id: String = "test-id",
        name: String = "Test City",
        fullName: String = "Test City, Country",
        country: String = "Testland",
        continent: String = "Europe"
    ) -> City {
        City(
            id: id,
            name: name,
            fullName: fullName,
            country: country,
            continent: continent,
            latitude: 40.0,
            longitude: -74.0,
            population: 1_000_000,
            teleportCityScore: 75.0,
            summary: "A great city",
            imageUrl: "https://example.com/city.jpg"
        )
    }

    private func sampleCityWithScores(
        id: String = "test-id",
        scores: [String: Double] = [
            "Cost of Living": 6.5,
            "Environmental Quality": 7.2,
            "Leisure & Culture": 8.0,
            "Economy": 5.0,
            "Safety": 7.5,
            "Commute": 4.5,
            "Healthcare": 6.0,
            "Outdoors": 8.0,
        ]
    ) -> CityWithScores {
        CityWithScores(city: sampleCity(id: id), scores: scores)
    }

    // MARK: - City Tests

    @Test func cityHashEquality_sameId() {
        let city1 = sampleCity(id: "abc", name: "City A")
        let city2 = sampleCity(id: "abc", name: "City B")
        #expect(city1 == city2, "Cities with same id should be equal")
        #expect(city1.hashValue == city2.hashValue)
    }

    @Test func cityHashEquality_differentId() {
        let city1 = sampleCity(id: "abc")
        let city2 = sampleCity(id: "xyz")
        #expect(city1 != city2, "Cities with different ids should not be equal")
    }

    @Test func cityCodableRoundTrip() throws {
        let city = sampleCity()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(city)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(City.self, from: data)
        #expect(decoded.id == city.id)
        #expect(decoded.name == city.name)
        #expect(decoded.fullName == city.fullName)
        #expect(decoded.country == city.country)
        #expect(decoded.latitude == city.latitude)
    }

    @Test func cityCodableWithNilOptionals() throws {
        let city = City(
            id: "min",
            name: "Minimal",
            fullName: "Minimal City",
            country: "X",
            continent: "Y",
            latitude: 0,
            longitude: 0,
            population: nil,
            teleportCityScore: nil,
            summary: nil,
            imageUrl: nil
        )
        let data = try JSONEncoder().encode(city)
        let decoded = try JSONDecoder().decode(City.self, from: data)
        #expect(decoded.population == nil)
        #expect(decoded.teleportCityScore == nil)
        #expect(decoded.summary == nil)
        #expect(decoded.imageUrl == nil)
    }

    // MARK: - CityWithScores Tests

    @Test func cityWithScores_scoreForExistingCategory() {
        let cws = sampleCityWithScores()
        #expect(cws.score(for: "Safety") == 7.5)
    }

    @Test func cityWithScores_scoreForMissingCategory() {
        let cws = sampleCityWithScores()
        #expect(cws.score(for: "Nonexistent") == 0)
    }

    @Test func cityWithScores_displayMetricsCount() {
        let cws = sampleCityWithScores()
        #expect(cws.displayMetrics.count == 5)
    }

    @Test func cityWithScores_displayMetricsCategories() {
        let cws = sampleCityWithScores()
        let categories = cws.displayMetrics.map { $0.category }
        #expect(categories.contains("Cost of Living"))
        #expect(categories.contains("Climate"))
        #expect(categories.contains("Culture"))
        #expect(categories.contains("Jobs"))
        #expect(categories.contains("Mobility"))
    }

    @Test func metricLabel_costOfLiving_affordable() {
        let cws = sampleCityWithScores(scores: ["Cost of Living": 7.0])
        let metric = cws.displayMetrics.first { $0.category == "Cost of Living" }!
        #expect(metric.label == "Affordable")
    }

    @Test func metricLabel_costOfLiving_moderate() {
        let cws = sampleCityWithScores(scores: ["Cost of Living": 4.0])
        let metric = cws.displayMetrics.first { $0.category == "Cost of Living" }!
        #expect(metric.label == "Moderate")
    }

    @Test func metricLabel_costOfLiving_highCost() {
        let cws = sampleCityWithScores(scores: ["Cost of Living": 3.0])
        let metric = cws.displayMetrics.first { $0.category == "Cost of Living" }!
        #expect(metric.label == "High Cost")
    }

    @Test func metricLabel_environmentalQuality_optimal() {
        let cws = sampleCityWithScores(scores: ["Environmental Quality": 8.0])
        let metric = cws.displayMetrics.first { $0.category == "Climate" }!
        #expect(metric.label == "Optimal")
    }

    @Test func metricLabel_leisureAndCulture_vibrant() {
        let cws = sampleCityWithScores(scores: ["Leisure & Culture": 7.5])
        let metric = cws.displayMetrics.first { $0.category == "Culture" }!
        #expect(metric.label == "Vibrant")
    }

    @Test func metricLabel_economy_highGrowth() {
        let cws = sampleCityWithScores(scores: ["Economy": 9.0])
        let metric = cws.displayMetrics.first { $0.category == "Jobs" }!
        #expect(metric.label == "High Growth")
    }

    @Test func metricLabel_economy_developing() {
        let cws = sampleCityWithScores(scores: ["Economy": 2.0])
        let metric = cws.displayMetrics.first { $0.category == "Jobs" }!
        #expect(metric.label == "Developing")
    }

    @Test func metricLabel_commute_excellent() {
        let cws = sampleCityWithScores(scores: ["Commute": 8.0])
        let metric = cws.displayMetrics.first { $0.category == "Mobility" }!
        #expect(metric.label == "Excellent Public Transit")
    }

    @Test func metricLabel_commute_carDependent() {
        let cws = sampleCityWithScores(scores: ["Commute": 2.0])
        let metric = cws.displayMetrics.first { $0.category == "Mobility" }!
        #expect(metric.label == "Car Dependent")
    }

    // MARK: - UserPreferences Tests

    @Test func userPreferences_defaults() {
        let defaults = UserPreferences.defaults
        #expect(defaults.startType == .cityILove)
        #expect(defaults.costPreference == 5.0)
        #expect(defaults.climatePreference == 5.0)
        #expect(defaults.culturePreference == 5.0)
        #expect(defaults.jobMarketPreference == 5.0)
        #expect(defaults.safetyPreference == 5.0)
        #expect(defaults.commutePreference == 5.0)
        #expect(defaults.healthcarePreference == 5.0)
        #expect(defaults.selectedVibeTags == nil)
        #expect(defaults.signalWeights == nil)
    }

    @Test func userPreferences_fromCity() {
        let city = sampleCityWithScores(scores: [
            "Cost of Living": 8.0,
            "Environmental Quality": 6.5,
            "Leisure & Culture": 7.0,
            "Economy": 5.0,
            "Safety": 9.0,
            "Commute": 3.0,
            "Healthcare": 4.0,
        ])
        let prefs = UserPreferences.fromCity(city)
        #expect(prefs.startType == .cityILove)
        #expect(prefs.costPreference == 8.0)
        #expect(prefs.climatePreference == 6.5)
        #expect(prefs.culturePreference == 7.0)
        #expect(prefs.jobMarketPreference == 5.0)
        #expect(prefs.safetyPreference == 9.0)
        #expect(prefs.commutePreference == 3.0)
        #expect(prefs.healthcarePreference == 4.0)
    }

    @Test func userPreferences_fromCity_missingScores() {
        let city = sampleCityWithScores(scores: [:]) // no scores
        let prefs = UserPreferences.fromCity(city)
        #expect(prefs.costPreference == 0) // score(for:) returns 0, clamped to 0
    }

    @Test func userPreferences_fromCity_clampedAbove10() {
        // Scores should be 0-10 but test clamping
        let city = sampleCityWithScores(scores: ["Cost of Living": 15.0])
        let prefs = UserPreferences.fromCity(city)
        #expect(prefs.costPreference == 10.0) // clamped to 10
    }

    @Test func userPreferences_codableBackwardCompat() throws {
        // JSON missing optional fields → should default to 5.0
        let json = """
        {
            "start_type": "city_i_love",
            "cost_preference": 8.0
        }
        """.data(using: .utf8)!
        let prefs = try JSONDecoder().decode(UserPreferences.self, from: json)
        #expect(prefs.costPreference == 8.0)
        #expect(prefs.climatePreference == 5.0) // defaulted
        #expect(prefs.signalWeights == nil) // optional stays nil
    }

    @Test func userPreferences_codableRoundTripWithSignalWeights() throws {
        var prefs = UserPreferences.defaults
        prefs.signalWeights = ["climate": 3.0, "cost": 2.0]
        let data = try JSONEncoder().encode(prefs)
        let decoded = try JSONDecoder().decode(UserPreferences.self, from: data)
        #expect(decoded.signalWeights?["climate"] == 3.0)
        #expect(decoded.signalWeights?["cost"] == 2.0)
    }

    @Test func userPreferences_codableRoundTripNilSignalWeights() throws {
        let prefs = UserPreferences.defaults
        let data = try JSONEncoder().encode(prefs)
        let decoded = try JSONDecoder().decode(UserPreferences.self, from: data)
        #expect(decoded.signalWeights == nil)
    }

    // MARK: - StartType Tests

    @Test func startType_rawValues() {
        #expect(StartType.cityILove.rawValue == "city_i_love")
        #expect(StartType.vibes.rawValue == "vibes")
        #expect(StartType.myWords.rawValue == "my_words")
    }

    @Test func startType_codableRoundTrip() throws {
        for startType in [StartType.cityILove, .vibes, .myWords] {
            let data = try JSONEncoder().encode(startType)
            let decoded = try JSONDecoder().decode(StartType.self, from: data)
            #expect(decoded == startType)
        }
    }
}
