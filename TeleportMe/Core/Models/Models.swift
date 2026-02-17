import Foundation

// MARK: - City

struct City: Codable, Identifiable, Hashable {
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

    enum CodingKeys: String, CodingKey {
        case id, name, country, continent, latitude, longitude, population, summary
        case fullName = "full_name"
        case teleportCityScore = "teleport_city_score"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(id: String, name: String, fullName: String, country: String, continent: String,
         latitude: Double, longitude: Double, population: Int?, teleportCityScore: Double?,
         summary: String?, imageUrl: String?, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.country = country
        self.continent = continent
        self.latitude = latitude
        self.longitude = longitude
        self.population = population
        self.teleportCityScore = teleportCityScore
        self.summary = summary
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - City Score

struct CityScore: Codable, Identifiable {
    let id: String?
    let cityId: String
    let category: String
    let score: Double

    enum CodingKeys: String, CodingKey {
        case id, category, score
        case cityId = "city_id"
    }
}

// MARK: - City Insights

struct CityInsights: Codable {
    let cityId: String
    let knownFor: [String]
    let concerns: [String]
    let generatedAt: String

    enum CodingKeys: String, CodingKey {
        case cityId = "city_id"
        case knownFor = "known_for"
        case concerns
        case generatedAt = "generated_at"
    }
}

// MARK: - City with Scores (convenience)

struct CityWithScores: Codable, Identifiable, Hashable {
    let city: City
    let scores: [String: Double]

    var id: String { city.id }

    func score(for category: String) -> Double {
        scores[category] ?? 0
    }

    // Grouped scores for display
    var displayMetrics: [CityMetric] {
        [
            CityMetric(category: "Cost of Living", icon: "banknote", score: score(for: "Cost of Living"), label: metricLabel(for: "Cost of Living")),
            CityMetric(category: "Climate", icon: "sun.max", score: score(for: "Environmental Quality"), label: metricLabel(for: "Environmental Quality")),
            CityMetric(category: "Culture", icon: "theatermasks", score: score(for: "Leisure & Culture"), label: metricLabel(for: "Leisure & Culture")),
            CityMetric(category: "Jobs", icon: "briefcase", score: score(for: "Economy"), label: metricLabel(for: "Economy")),
            CityMetric(category: "Mobility", icon: "tram", score: score(for: "Commute"), label: metricLabel(for: "Commute")),
        ]
    }

    private func metricLabel(for category: String) -> String {
        let s = score(for: category)
        switch category {
        case "Cost of Living":
            return s >= 7 ? "Affordable" : s >= 4 ? "Moderate" : "High Cost"
        case "Environmental Quality":
            return s >= 7 ? "Optimal" : s >= 4 ? "Moderate" : "Challenging"
        case "Leisure & Culture":
            return s >= 7 ? "Vibrant" : s >= 4 ? "Moderate" : "Limited"
        case "Economy":
            return s >= 7 ? "High Growth" : s >= 4 ? "Stable" : "Developing"
        case "Commute":
            return s >= 7 ? "Excellent Public Transit" : s >= 4 ? "Moderate" : "Car Dependent"
        default:
            return s >= 7 ? "Strong" : s >= 4 ? "Average" : "Limited"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(city.id)
    }

    static func == (lhs: CityWithScores, rhs: CityWithScores) -> Bool {
        lhs.city.id == rhs.city.id
    }
}

struct CityMetric: Identifiable {
    let category: String
    let icon: String
    let score: Double
    let label: String
    var id: String { category }
}

// MARK: - User Profile

struct UserProfile: Codable {
    let id: String
    var name: String
    var email: String?
    var currentCityId: String?
    var avatarUrl: String?
    let createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case currentCityId = "current_city_id"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var startType: StartType
    var costPreference: Double
    var climatePreference: Double
    var culturePreference: Double
    var jobMarketPreference: Double
    var safetyPreference: Double
    var commutePreference: Double
    var healthcarePreference: Double
    var selectedVibeTags: [String]?
    var signalWeights: [String: Double]?

    enum CodingKeys: String, CodingKey {
        case startType = "start_type"
        case costPreference = "cost_preference"
        case climatePreference = "climate_preference"
        case culturePreference = "culture_preference"
        case jobMarketPreference = "job_market_preference"
        case safetyPreference = "safety_preference"
        case commutePreference = "commute_preference"
        case healthcarePreference = "healthcare_preference"
        case selectedVibeTags = "selected_vibe_tags"
        case signalWeights = "signal_weights"
    }

    static var defaults: UserPreferences {
        UserPreferences(
            startType: .cityILove,
            costPreference: 5.0,
            climatePreference: 5.0,
            culturePreference: 5.0,
            jobMarketPreference: 5.0,
            safetyPreference: 5.0,
            commutePreference: 5.0,
            healthcarePreference: 5.0,
            selectedVibeTags: nil,
            signalWeights: nil
        )
    }

    /// Prefill preferences based on a city's actual scores.
    /// Maps each score category to its corresponding preference,
    /// so the user starts with values that reflect their chosen city.
    static func fromCity(_ city: CityWithScores) -> UserPreferences {
        UserPreferences(
            startType: .cityILove,
            costPreference: city.score(for: "Cost of Living").clamped(to: 0...10),
            climatePreference: city.score(for: "Environmental Quality").clamped(to: 0...10),
            culturePreference: city.score(for: "Leisure & Culture").clamped(to: 0...10),
            jobMarketPreference: city.score(for: "Economy").clamped(to: 0...10),
            safetyPreference: city.score(for: "Safety").clamped(to: 0...10),
            commutePreference: city.score(for: "Commute").clamped(to: 0...10),
            healthcarePreference: city.score(for: "Healthcare").clamped(to: 0...10),
            selectedVibeTags: nil
        )
    }

    // Support decoding from older caches that lack the new fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startType = try container.decodeIfPresent(StartType.self, forKey: .startType) ?? .cityILove
        costPreference = try container.decodeIfPresent(Double.self, forKey: .costPreference) ?? 5.0
        climatePreference = try container.decodeIfPresent(Double.self, forKey: .climatePreference) ?? 5.0
        culturePreference = try container.decodeIfPresent(Double.self, forKey: .culturePreference) ?? 5.0
        jobMarketPreference = try container.decodeIfPresent(Double.self, forKey: .jobMarketPreference) ?? 5.0
        safetyPreference = try container.decodeIfPresent(Double.self, forKey: .safetyPreference) ?? 5.0
        commutePreference = try container.decodeIfPresent(Double.self, forKey: .commutePreference) ?? 5.0
        healthcarePreference = try container.decodeIfPresent(Double.self, forKey: .healthcarePreference) ?? 5.0
        selectedVibeTags = try container.decodeIfPresent([String].self, forKey: .selectedVibeTags)
        signalWeights = try container.decodeIfPresent([String: Double].self, forKey: .signalWeights)
    }

    init(
        startType: StartType = .cityILove,
        costPreference: Double = 5.0,
        climatePreference: Double = 5.0,
        culturePreference: Double = 5.0,
        jobMarketPreference: Double = 5.0,
        safetyPreference: Double = 5.0,
        commutePreference: Double = 5.0,
        healthcarePreference: Double = 5.0,
        selectedVibeTags: [String]? = nil,
        signalWeights: [String: Double]? = nil
    ) {
        self.startType = startType
        self.costPreference = costPreference
        self.climatePreference = climatePreference
        self.culturePreference = culturePreference
        self.jobMarketPreference = jobMarketPreference
        self.safetyPreference = safetyPreference
        self.commutePreference = commutePreference
        self.healthcarePreference = healthcarePreference
        self.selectedVibeTags = selectedVibeTags
        self.signalWeights = signalWeights
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

enum StartType: String, Codable {
    case cityILove = "city_i_love"
    case vibes = "vibes"
    case myWords = "my_words"
}

// MARK: - Vibe Tags

struct VibeTag: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String?
    let category: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, category
        case createdAt = "created_at"
    }
}

enum VibeCategory: String, CaseIterable {
    case lifestyle
    case culture
    case pace
    case values
    case environment

    var displayName: String {
        switch self {
        case .lifestyle: "Lifestyle"
        case .culture: "Culture"
        case .pace: "Pace"
        case .values: "Values"
        case .environment: "Environment"
        }
    }
}

// MARK: - Exploration (named, repeatable analysis)

struct Exploration: Codable, Identifiable, Hashable {
    let id: String?
    let userId: String?
    var title: String
    let startType: StartType
    let baselineCityId: String?
    let preferences: ReportPreferences?
    let results: [CityMatch]
    let aiSummary: String?
    let vibeTags: [String]?
    let freeText: String?
    let compassVibes: [String: Double]?
    let compassConstraints: TripConstraints?
    let createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, preferences, results, title
        case userId = "user_id"
        case startType = "start_type"
        case baselineCityId = "baseline_city_id"
        case aiSummary = "ai_summary"
        case vibeTags = "vibe_tags"
        case freeText = "free_text"
        case compassVibes = "compass_vibes"
        case compassConstraints = "compass_constraints"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Exploration, rhs: Exploration) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - City Report (legacy — from edge function)

struct CityReport: Codable, Identifiable, Hashable {
    let id: String?
    let userId: String?
    let currentCityId: String?
    let preferences: ReportPreferences?
    let results: [CityMatch]
    let aiSummary: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, preferences, results
        case userId = "user_id"
        case currentCityId = "current_city_id"
        case aiSummary = "ai_summary"
        case createdAt = "created_at"
    }

    // Hash and equality by id for NavigationStack
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CityReport, rhs: CityReport) -> Bool {
        lhs.id == rhs.id
    }
}

struct ReportPreferences: Codable {
    let cost: Double
    let climate: Double
    let culture: Double
    let jobMarket: Double

    enum CodingKeys: String, CodingKey {
        case cost, climate, culture
        case jobMarket = "job_market"
    }
}

struct CityMatch: Codable, Identifiable {
    let cityId: String
    let cityName: String
    let cityFullName: String
    let cityCountry: String
    let cityImageUrl: String?
    let matchPercent: Int
    let rank: Int
    let comparison: [String: ComparisonMetric]?
    let aiInsight: String?
    let scores: [String: Double]?

    var id: String { cityId }

    enum CodingKeys: String, CodingKey {
        case comparison, rank, scores
        case cityId = "city_id"
        case cityName = "city_name"
        case cityFullName = "city_full_name"
        case cityCountry = "city_country"
        case cityImageUrl = "city_image_url"
        case matchPercent = "match_percent"
        case aiInsight = "ai_insight"
    }
}

struct ComparisonMetric: Codable {
    let matchScore: Double
    let currentScore: Double
    let delta: Double

    enum CodingKeys: String, CodingKey {
        case delta
        case matchScore = "match_score"
        case currentScore = "current_score"
    }
}

// MARK: - Edge Function Response

struct GenerateReportResponse: Codable {
    let reportId: String?
    let explorationId: String?
    let currentCity: CurrentCityInfo?
    let matches: [CityMatch]

    init(reportId: String?, explorationId: String? = nil, currentCity: CurrentCityInfo?, matches: [CityMatch]) {
        self.reportId = reportId
        self.explorationId = explorationId
        self.currentCity = currentCity
        self.matches = matches
    }

    enum CodingKeys: String, CodingKey {
        case matches
        case reportId = "report_id"
        case explorationId = "exploration_id"
        case currentCity = "current_city"
    }
}

struct CurrentCityInfo: Codable {
    let id: String
    let name: String
    let scores: [String: Double]
}

// MARK: - Results View Model (unified display model)

/// Normalizes data from `GenerateReportResponse`, `Exploration`, and `CityReport`
/// into a single shape for `ReportDetailView`.
struct ResultsViewModel {
    let title: String
    let matches: [CityMatch]
    let currentCityId: String?
    let currentCityName: String?
    let aiSummary: String?
    let createdAt: Date?

    /// Optional exploration reference (enables rename/delete actions in toolbar)
    let exploration: Exploration?

    /// Source type — controls header label and analytics context
    let source: Source

    enum Source {
        case onboarding          // Post-onboarding generation
        case newExploration      // Post-new-exploration generation
        case pastExploration     // Viewing a saved Exploration from Discover
        case legacyReport        // Viewing a legacy CityReport
    }

    // MARK: - Convenience initializers

    init(from response: GenerateReportResponse, title: String = "City Recommendations", source: Source = .onboarding) {
        self.title = title
        self.matches = response.matches
        self.currentCityId = response.currentCity?.id
        self.currentCityName = response.currentCity?.name
        self.aiSummary = nil
        self.createdAt = nil
        self.exploration = nil
        self.source = source
    }

    init(from exploration: Exploration) {
        self.title = exploration.title
        self.matches = exploration.results
        self.currentCityId = exploration.baselineCityId
        self.currentCityName = nil  // resolved by the view via CityService
        self.aiSummary = exploration.aiSummary
        self.createdAt = exploration.createdAt
        self.exploration = exploration
        self.source = .pastExploration
    }

    init(from report: CityReport) {
        self.title = "City Recommendations"
        self.matches = report.results
        self.currentCityId = report.currentCityId
        self.currentCityName = nil  // resolved by the view via CityService
        self.aiSummary = report.aiSummary
        self.createdAt = report.createdAt
        self.exploration = nil
        self.source = .legacyReport
    }
}

// MARK: - Saved City

struct SavedCity: Codable, Identifiable {
    let id: String?
    let userId: String
    let cityId: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cityId = "city_id"
        case createdAt = "created_at"
    }
}

// MARK: - Engagement Event

struct EngagementEvent: Codable {
    let eventType: String
    let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
        case eventType = "event_type"
        case metadata
    }
}
