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

    enum CodingKeys: String, CodingKey {
        case startType = "start_type"
        case costPreference = "cost_preference"
        case climatePreference = "climate_preference"
        case culturePreference = "culture_preference"
        case jobMarketPreference = "job_market_preference"
    }

    static var defaults: UserPreferences {
        UserPreferences(
            startType: .cityILove,
            costPreference: 5.0,
            climatePreference: 5.0,
            culturePreference: 5.0,
            jobMarketPreference: 5.0
        )
    }
}

enum StartType: String, Codable {
    case cityILove = "city_i_love"
    case vibes = "vibes"
    case myWords = "my_words"
}

// MARK: - City Report (from edge function)

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
    let currentCity: CurrentCityInfo?
    let matches: [CityMatch]

    enum CodingKeys: String, CodingKey {
        case matches
        case reportId = "report_id"
        case currentCity = "current_city"
    }
}

struct CurrentCityInfo: Codable {
    let id: String
    let name: String
    let scores: [String: Double]
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
