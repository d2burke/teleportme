import Foundation

// MARK: - Service Protocols
//
// Lightweight protocols that mirror the public API of each service.
// The concrete services already conform to these interfaces — we just need
// to declare conformance. Mock implementations live in the test target.

// MARK: - CityServiceProtocol

protocol CityServiceProtocol: AnyObject {
    var allCities: [City] { get }
    var isLoading: Bool { get }
    var loadError: String? { get }

    func fetchAllCities() async
    func fetchAllScores() async
    func searchCities(query: String) async -> [City]
    func getCityWithScores(cityId: String) async -> CityWithScores?
    func getCitiesWithScores(cityIds: [String]) async -> [CityWithScores]
    func similarCities(to cityId: String, limit: Int) -> [CityService.SimilarCity]
    func getCityInsights(cityId: String) async -> CityInsights?
}

// MARK: - ExplorationServiceProtocol

protocol ExplorationServiceProtocol: AnyObject {
    var explorations: [Exploration] { get set }
    var isGenerating: Bool { get }
    var isLoading: Bool { get }
    var error: String? { get set }

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
    ) async throws -> GenerateReportResponse

    func loadExplorations(userId: String) async
    func renameExploration(id: String, newTitle: String, userId: String) async
    func deleteExploration(id: String, userId: String) async
    func restoreFromCache(userId: String)
    func saveSignalWeights(_ weights: [String: Double], userId: String) async throws
    func fetchSignalWeights(userId: String) async throws -> [String: Double]?
}

// MARK: - ReportServiceProtocol

protocol ReportServiceProtocol: AnyObject {
    var currentReport: GenerateReportResponse? { get set }
    var isGenerating: Bool { get }
    var error: String? { get set }

    func loadReports(userId: String) async -> [CityReport]
    func restoreCurrentReport(userId: String)
}

// MARK: - SavedCitiesServiceProtocol

protocol SavedCitiesServiceProtocol: AnyObject {
    var savedCityIds: Set<String> { get set }
    var savedCities: [SavedCity] { get set }
    var isLoading: Bool { get }
    var cachedUserId: String? { get set }

    func loadSavedCities() async
    func toggleSave(cityId: String) async
    func isSaved(cityId: String) -> Bool
}

// MARK: - Conformance Declarations

extension CityService: CityServiceProtocol {}
extension ExplorationService: ExplorationServiceProtocol {}
extension ReportService: ReportServiceProtocol {}
extension SavedCitiesService: SavedCitiesServiceProtocol {}
