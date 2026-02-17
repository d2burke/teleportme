import Testing
import Foundation
@testable import TeleportMe

// MARK: - Mock Exploration Service Integration Tests
//
// These tests verify the mock service behaves correctly and can be used
// to test coordinator/view logic that depends on ExplorationService.

struct MockExplorationServiceTests {

    // MARK: - Generate

    @Test func generate_returnsConfiguredResult() async throws {
        let mock = MockExplorationService()
        let expected = TestFixtures.sampleGenerateReportResponse()
        mock.generateResult = expected

        let result = try await mock.generateExploration(
            title: "Test",
            startType: .vibes,
            baselineCityId: nil,
            preferences: .defaults,
            vibeTags: nil,
            userVibeTags: nil,
            compassVibes: nil,
            compassConstraints: nil,
            userId: nil
        )

        #expect(mock.generateCalled)
        #expect(mock.generateTitle == "Test")
        #expect(result.matches.count == expected.matches.count)
    }

    @Test func generate_throwsConfiguredError() async {
        let mock = MockExplorationService()
        mock.generateError = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Network error"])

        do {
            _ = try await mock.generateExploration(
                title: "Test",
                startType: .vibes,
                baselineCityId: nil,
                preferences: .defaults,
                vibeTags: nil,
                userVibeTags: nil,
                compassVibes: nil,
                compassConstraints: nil,
                userId: nil
            )
            #expect(Bool(false), "Should have thrown")
        } catch {
            #expect(error.localizedDescription.contains("Network error"))
        }
    }

    @Test func generate_setsIsGeneratingDuringExecution() async throws {
        let mock = MockExplorationService()
        mock.generateResult = TestFixtures.sampleGenerateReportResponse()

        // After the call completes, isGenerating should be false
        _ = try await mock.generateExploration(
            title: "Test",
            startType: .vibes,
            baselineCityId: nil,
            preferences: .defaults,
            vibeTags: nil,
            userVibeTags: nil,
            compassVibes: nil,
            compassConstraints: nil,
            userId: nil
        )
        #expect(!mock.isGenerating)
    }

    // MARK: - Rename

    @Test func rename_updatesLocalExplorations() async {
        let mock = MockExplorationService()
        mock.explorations = [
            TestFixtures.sampleExploration(id: "exp-1", title: "Old Title"),
            TestFixtures.sampleExploration(id: "exp-2", title: "Other"),
        ]

        await mock.renameExploration(id: "exp-1", newTitle: "New Title", userId: "user-1")

        #expect(mock.renamedIds.count == 1)
        #expect(mock.renamedIds[0].id == "exp-1")
        #expect(mock.renamedIds[0].newTitle == "New Title")
        #expect(mock.explorations.first { $0.id == "exp-1" }?.title == "New Title")
    }

    @Test func rename_nonexistentId_tracksButDoesNotCrash() async {
        let mock = MockExplorationService()
        mock.explorations = [
            TestFixtures.sampleExploration(id: "exp-1"),
        ]

        await mock.renameExploration(id: "nonexistent", newTitle: "Test", userId: "user-1")

        #expect(mock.renamedIds.count == 1)
        #expect(mock.explorations.count == 1) // unchanged
    }

    // MARK: - Delete

    @Test func delete_removesFromLocalExplorations() async {
        let mock = MockExplorationService()
        mock.explorations = [
            TestFixtures.sampleExploration(id: "exp-1"),
            TestFixtures.sampleExploration(id: "exp-2"),
            TestFixtures.sampleExploration(id: "exp-3"),
        ]

        await mock.deleteExploration(id: "exp-2", userId: "user-1")

        #expect(mock.deletedIds == ["exp-2"])
        #expect(mock.explorations.count == 2)
        #expect(mock.explorations.contains { $0.id == "exp-1" })
        #expect(!mock.explorations.contains { $0.id == "exp-2" })
        #expect(mock.explorations.contains { $0.id == "exp-3" })
    }

    @Test func delete_nonexistentId_tracksButDoesNotCrash() async {
        let mock = MockExplorationService()
        mock.explorations = [
            TestFixtures.sampleExploration(id: "exp-1"),
        ]

        await mock.deleteExploration(id: "nonexistent", userId: "user-1")

        #expect(mock.deletedIds == ["nonexistent"])
        #expect(mock.explorations.count == 1) // unchanged
    }

    // MARK: - Load Explorations

    @Test func loadExplorations_tracksCall() async {
        let mock = MockExplorationService()
        await mock.loadExplorations(userId: "user-123")
        #expect(mock.loadExplorationsCalled)
        #expect(mock.loadExplorationsUserId == "user-123")
    }

    // MARK: - Restore from Cache

    @Test func restoreFromCache_tracksCall() {
        let mock = MockExplorationService()
        mock.restoreFromCache(userId: "user-123")
        #expect(mock.restoreFromCacheCalled)
    }

    // MARK: - Signal Weights

    @Test func saveSignalWeights_storesWeights() async throws {
        let mock = MockExplorationService()
        let weights: [String: Double] = ["climate": 3.0, "cost": 2.0]
        try await mock.saveSignalWeights(weights, userId: "user-1")
        #expect(mock.saveSignalWeightsCalled)
        #expect(mock.savedSignalWeights?["climate"] == 3.0)
        #expect(mock.savedSignalWeights?["cost"] == 2.0)
    }

    @Test func fetchSignalWeights_returnsConfigured() async throws {
        let mock = MockExplorationService()
        mock.signalWeightsToReturn = ["climate": 3.0, "safety": 1.5]
        let result = try await mock.fetchSignalWeights(userId: "user-1")
        #expect(result?["climate"] == 3.0)
        #expect(result?["safety"] == 1.5)
    }

    @Test func fetchSignalWeights_returnsNilWhenNotConfigured() async throws {
        let mock = MockExplorationService()
        let result = try await mock.fetchSignalWeights(userId: "user-1")
        #expect(result == nil)
    }

    @Test func fetchSignalWeights_throwsConfiguredError() async {
        let mock = MockExplorationService()
        mock.fetchSignalWeightsError = NSError(domain: "test", code: 1)
        do {
            _ = try await mock.fetchSignalWeights(userId: "user-1")
            #expect(Bool(false), "Should have thrown")
        } catch {
            // Expected
        }
    }
}

// MARK: - Mock City Service Tests

struct MockCityServiceTests {

    @Test func fetchAllCities_setsAllCities() async {
        let mock = MockCityService()
        let cities = [
            TestFixtures.sampleCity(id: "c1", name: "Paris"),
            TestFixtures.sampleCity(id: "c2", name: "London"),
        ]
        mock.citiesToReturn = cities
        await mock.fetchAllCities()
        #expect(mock.fetchAllCitiesCalled)
        #expect(mock.allCities.count == 2)
    }

    @Test func searchCities_returnsConfigured() async {
        let mock = MockCityService()
        mock.searchResults = [TestFixtures.sampleCity(id: "c1", name: "Paris")]
        let results = await mock.searchCities(query: "Par")
        #expect(mock.searchQuery == "Par")
        #expect(results.count == 1)
        #expect(results[0].name == "Paris")
    }

    @Test func getCityWithScores_returnsConfigured() async {
        let mock = MockCityService()
        let expected = TestFixtures.sampleCityWithScores(id: "c1")
        mock.cityWithScoresToReturn = expected
        let result = await mock.getCityWithScores(cityId: "c1")
        #expect(mock.getCityWithScoresId == "c1")
        #expect(result?.city.id == "c1")
    }

    @Test func getCityWithScores_returnsNilByDefault() async {
        let mock = MockCityService()
        let result = await mock.getCityWithScores(cityId: "c1")
        #expect(result == nil)
    }
}

// MARK: - Mock Saved Cities Service Tests

struct MockSavedCitiesServiceTests {

    @Test func toggleSave_addsAndRemoves() async {
        let mock = MockSavedCitiesService()
        #expect(!mock.isSaved(cityId: "c1"))

        await mock.toggleSave(cityId: "c1")
        #expect(mock.isSaved(cityId: "c1"))
        #expect(mock.toggledCityIds == ["c1"])

        await mock.toggleSave(cityId: "c1")
        #expect(!mock.isSaved(cityId: "c1"))
        #expect(mock.toggledCityIds == ["c1", "c1"])
    }

    @Test func loadSavedCities_tracksCall() async {
        let mock = MockSavedCitiesService()
        await mock.loadSavedCities()
        #expect(mock.loadSavedCitiesCalled)
    }
}

// MARK: - Mock Report Service Tests

struct MockReportServiceTests {

    @Test func loadReports_returnsConfigured() async {
        let mock = MockReportService()
        // Returns empty by default
        let reports = await mock.loadReports(userId: "user-1")
        #expect(mock.loadReportsCalled)
        #expect(reports.isEmpty)
    }

    @Test func restoreCurrentReport_tracksCall() {
        let mock = MockReportService()
        mock.restoreCurrentReport(userId: "user-1")
        #expect(mock.restoreCurrentReportCalled)
    }
}

// MARK: - TestFixtures Tests

struct TestFixturesTests {

    @Test func sampleCity_defaultValues() {
        let city = TestFixtures.sampleCity()
        #expect(city.id == "test-city-id")
        #expect(city.name == "Test City")
        #expect(city.country == "Testland")
        #expect(city.latitude == 48.8566)
    }

    @Test func sampleCity_customValues() {
        let city = TestFixtures.sampleCity(id: "custom", name: "Custom City", country: "Customland")
        #expect(city.id == "custom")
        #expect(city.name == "Custom City")
        #expect(city.country == "Customland")
    }

    @Test func sampleCityWithScores_defaultScores() {
        let cws = TestFixtures.sampleCityWithScores()
        #expect(cws.score(for: "Safety") == 7.5)
        #expect(cws.score(for: "Cost of Living") == 6.5)
    }

    @Test func sampleExploration_defaultValues() {
        let exp = TestFixtures.sampleExploration()
        #expect(exp.id == "exploration-1")
        #expect(exp.title == "Test Exploration")
        #expect(exp.userId == "user-123")
        #expect(!exp.results.isEmpty)
    }

    @Test func sampleCityMatch_defaultValues() {
        let match = TestFixtures.sampleCityMatch()
        #expect(match.cityId == "match-city-1")
        #expect(match.cityName == "Barcelona")
        #expect(match.cityCountry == "Spain")
        #expect(match.matchPercent == 92)
    }

    @Test func sampleGenerateReportResponse_matchCount() {
        let response = TestFixtures.sampleGenerateReportResponse(matchCount: 3)
        #expect(response.matches.count == 3)
        #expect(response.matches[0].matchPercent == 95)
        #expect(response.matches[1].matchPercent == 90)
        #expect(response.matches[2].matchPercent == 85)
    }

    @Test func sampleGenerateReportResponse_defaultFiveMatches() {
        let response = TestFixtures.sampleGenerateReportResponse()
        #expect(response.matches.count == 5)
        #expect(response.reportId == "report-1")
    }
}
