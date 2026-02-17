import Foundation
@testable import TeleportMe

// MARK: - Mock City Service

final class MockCityService: CityServiceProtocol {
    var allCities: [City] = []
    var isLoading: Bool = false
    var loadError: String?

    // Configurable responses
    var citiesToReturn: [City] = []
    var cityWithScoresToReturn: CityWithScores?
    var searchResults: [City] = []
    var citiesWithScoresToReturn: [CityWithScores] = []
    var similarCitiesToReturn: [CityService.SimilarCity] = []
    var cityInsightsToReturn: CityInsights?

    // Call tracking
    var fetchAllCitiesCalled = false
    var fetchAllScoresCalled = false
    var searchQuery: String?
    var getCityWithScoresId: String?
    var getCitiesWithScoresIds: [String]?

    func fetchAllCities() async {
        fetchAllCitiesCalled = true
        allCities = citiesToReturn
    }

    func fetchAllScores() async {
        fetchAllScoresCalled = true
    }

    func searchCities(query: String) async -> [City] {
        searchQuery = query
        return searchResults
    }

    func getCityWithScores(cityId: String) async -> CityWithScores? {
        getCityWithScoresId = cityId
        return cityWithScoresToReturn
    }

    func getCitiesWithScores(cityIds: [String]) async -> [CityWithScores] {
        getCitiesWithScoresIds = cityIds
        return citiesWithScoresToReturn
    }

    func similarCities(to cityId: String, limit: Int) -> [CityService.SimilarCity] {
        return similarCitiesToReturn
    }

    func getCityInsights(cityId: String) async -> CityInsights? {
        return cityInsightsToReturn
    }
}

// MARK: - Mock Exploration Service

final class MockExplorationService: ExplorationServiceProtocol {
    var explorations: [Exploration] = []
    var isGenerating: Bool = false
    var isLoading: Bool = false
    var error: String?

    // Configurable responses
    var generateResult: GenerateReportResponse?
    var generateError: Error?
    var savedSignalWeights: [String: Double]?
    var signalWeightsToReturn: [String: Double]?
    var fetchSignalWeightsError: Error?

    // Call tracking
    var generateCalled = false
    var generateTitle: String?
    var loadExplorationsCalled = false
    var loadExplorationsUserId: String?
    var renamedIds: [(id: String, newTitle: String)] = []
    var deletedIds: [String] = []
    var restoreFromCacheCalled = false
    var saveSignalWeightsCalled = false

    func generateExploration(
        title: String,
        startType: StartType,
        baselineCityId: String?,
        preferences: UserPreferences,
        vibeTags: [String]?,
        userVibeTags: [String]?,
        compassVibes: [String: Double]?,
        compassConstraints: TripConstraints?,
        userId: String?
    ) async throws -> GenerateReportResponse {
        generateCalled = true
        generateTitle = title
        isGenerating = true
        defer { isGenerating = false }

        if let err = generateError {
            throw err
        }
        guard let result = generateResult else {
            throw NSError(domain: "MockExplorationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No result configured"])
        }
        return result
    }

    func loadExplorations(userId: String) async {
        loadExplorationsCalled = true
        loadExplorationsUserId = userId
    }

    func renameExploration(id: String, newTitle: String, userId: String) async {
        renamedIds.append((id: id, newTitle: newTitle))
        if let index = explorations.firstIndex(where: { $0.id == id }) {
            explorations[index].title = newTitle
        }
    }

    func deleteExploration(id: String, userId: String) async {
        deletedIds.append(id)
        explorations.removeAll { $0.id == id }
    }

    func restoreFromCache(userId: String) {
        restoreFromCacheCalled = true
    }

    func saveSignalWeights(_ weights: [String: Double], userId: String) async throws {
        saveSignalWeightsCalled = true
        savedSignalWeights = weights
    }

    func fetchSignalWeights(userId: String) async throws -> [String: Double]? {
        if let err = fetchSignalWeightsError {
            throw err
        }
        return signalWeightsToReturn
    }
}

// MARK: - Mock Report Service

final class MockReportService: ReportServiceProtocol {
    var currentReport: GenerateReportResponse?
    var isGenerating: Bool = false
    var error: String?

    // Configurable responses
    var reportsToReturn: [CityReport] = []

    // Call tracking
    var loadReportsCalled = false
    var restoreCurrentReportCalled = false

    func loadReports(userId: String) async -> [CityReport] {
        loadReportsCalled = true
        return reportsToReturn
    }

    func restoreCurrentReport(userId: String) {
        restoreCurrentReportCalled = true
    }
}

// MARK: - Mock Saved Cities Service

final class MockSavedCitiesService: SavedCitiesServiceProtocol {
    var savedCityIds: Set<String> = []
    var savedCities: [SavedCity] = []
    var isLoading: Bool = false
    var cachedUserId: String?

    // Call tracking
    var loadSavedCitiesCalled = false
    var toggledCityIds: [String] = []

    func loadSavedCities() async {
        loadSavedCitiesCalled = true
    }

    func toggleSave(cityId: String) async {
        toggledCityIds.append(cityId)
        if savedCityIds.contains(cityId) {
            savedCityIds.remove(cityId)
        } else {
            savedCityIds.insert(cityId)
        }
    }

    func isSaved(cityId: String) -> Bool {
        savedCityIds.contains(cityId)
    }
}

// MARK: - Test Helpers

/// Factory for creating sample model instances in tests.
enum TestFixtures {

    static func sampleCity(
        id: String = "test-city-id",
        name: String = "Test City",
        fullName: String = "Test City, Testland",
        country: String = "Testland",
        continent: String = "Europe",
        latitude: Double = 48.8566,
        longitude: Double = 2.3522,
        population: Int? = 2_000_000,
        teleportCityScore: Double? = 80.0,
        summary: String? = "A beautiful test city",
        imageUrl: String? = "https://example.com/test.jpg"
    ) -> City {
        City(
            id: id,
            name: name,
            fullName: fullName,
            country: country,
            continent: continent,
            latitude: latitude,
            longitude: longitude,
            population: population,
            teleportCityScore: teleportCityScore,
            summary: summary,
            imageUrl: imageUrl
        )
    }

    static func sampleCityWithScores(
        id: String = "test-city-id",
        name: String = "Test City",
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
        CityWithScores(
            city: sampleCity(id: id, name: name),
            scores: scores
        )
    }

    static func sampleExploration(
        id: String = "exploration-1",
        title: String = "Test Exploration",
        userId: String = "user-123",
        compassVibes: [String: Double]? = nil,
        compassConstraints: TripConstraints? = nil
    ) -> Exploration {
        Exploration(
            id: id,
            userId: userId,
            title: title,
            startType: .vibes,
            baselineCityId: nil,
            preferences: nil,
            results: [sampleCityMatch()],
            aiSummary: nil,
            vibeTags: nil,
            freeText: nil,
            compassVibes: compassVibes,
            compassConstraints: compassConstraints,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func sampleCityMatch(
        cityId: String = "match-city-1",
        cityName: String = "Barcelona",
        cityCountry: String = "Spain",
        matchPercent: Int = 92,
        rank: Int = 1,
        aiInsight: String? = "Great weather and culture"
    ) -> CityMatch {
        CityMatch(
            cityId: cityId,
            cityName: cityName,
            cityFullName: "\(cityName), \(cityCountry)",
            cityCountry: cityCountry,
            cityImageUrl: "https://example.com/barcelona.jpg",
            matchPercent: matchPercent,
            rank: rank,
            comparison: nil,
            aiInsight: aiInsight,
            scores: nil
        )
    }

    static func sampleGenerateReportResponse(
        reportId: String = "report-1",
        matchCount: Int = 5
    ) -> GenerateReportResponse {
        let matches = (0..<matchCount).map { i in
            sampleCityMatch(
                cityId: "city-\(i)",
                cityName: "City \(i)",
                matchPercent: 95 - (i * 5),
                rank: i + 1
            )
        }
        return GenerateReportResponse(
            reportId: reportId,
            currentCity: nil,
            matches: matches
        )
    }
}
