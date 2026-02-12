import SwiftUI

// MARK: - Preview Helpers

/// A pre-configured AppCoordinator for SwiftUI Previews.
/// Provides mock data so views can render without a live Supabase connection.
enum PreviewHelpers {

    // MARK: - Mock Coordinator

    @MainActor
    static func makeCoordinator() -> AppCoordinator {
        let coordinator = AppCoordinator()
        coordinator.onboardingName = "Alex"
        coordinator.selectedStartType = .cityILove
        coordinator.selectedCityId = "san-francisco"
        coordinator.selectedCity = sampleCityWithScores
        coordinator.preferences = UserPreferences(
            startType: .cityILove,
            costPreference: 8,
            climatePreference: 6,
            culturePreference: 7,
            jobMarketPreference: 5
        )
        return coordinator
    }

    /// Coordinator with a mock report already loaded
    @MainActor
    static func makeCoordinatorWithReport() -> AppCoordinator {
        let coordinator = makeCoordinator()
        coordinator.reportService.currentReport = sampleReport
        return coordinator
    }

    // MARK: - Sample Data

    static let sampleCity = City(
        id: "san-francisco",
        name: "San Francisco",
        fullName: "San Francisco, California, United States",
        country: "United States",
        continent: "North America",
        latitude: 37.7749,
        longitude: -122.4194,
        population: 874961,
        teleportCityScore: 65.59,
        summary: "A global hub for technology and innovation.",
        imageUrl: "https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80",
        createdAt: nil,
        updatedAt: nil
    )

    static let sampleScores: [String: Double] = [
        "Housing": 2.0,
        "Cost of Living": 2.5,
        "Startups": 9.5,
        "Venture Capital": 9.0,
        "Travel Connectivity": 7.0,
        "Commute": 4.5,
        "Business Freedom": 8.0,
        "Safety": 5.0,
        "Healthcare": 7.5,
        "Education": 8.0,
        "Environmental Quality": 6.0,
        "Economy": 8.5,
        "Taxation": 4.0,
        "Internet Access": 8.5,
        "Leisure & Culture": 8.0,
        "Tolerance": 8.5,
        "Outdoors": 7.0,
    ]

    static let sampleCityWithScores = CityWithScores(
        city: sampleCity,
        scores: sampleScores
    )

    static let sampleMatches: [CityMatch] = [
        CityMatch(
            cityId: "berlin",
            cityName: "Berlin",
            cityFullName: "Berlin, Germany",
            cityCountry: "Germany",
            cityImageUrl: "https://images.unsplash.com/photo-1560969184-10fe8719e047?auto=format&fit=crop&w=800&q=80",
            matchPercent: 87,
            rank: 1,
            comparison: [
                "Cost of Living": ComparisonMetric(matchScore: 7.0, currentScore: 2.5, delta: 4.5),
                "Environmental Quality": ComparisonMetric(matchScore: 6.5, currentScore: 6.0, delta: 0.5),
                "Leisure & Culture": ComparisonMetric(matchScore: 9.0, currentScore: 8.0, delta: 1.0),
                "Economy": ComparisonMetric(matchScore: 7.0, currentScore: 8.5, delta: -1.5),
                "Commute": ComparisonMetric(matchScore: 8.0, currentScore: 4.5, delta: 3.5),
            ],
            aiInsight: "Berlin offers a vibrant cultural scene with significantly lower living costs, making it ideal for someone who prioritizes affordability without sacrificing creativity.",
            scores: ["Cost of Living": 7.0, "Environmental Quality": 6.5, "Leisure & Culture": 9.0, "Economy": 7.0, "Commute": 8.0]
        ),
        CityMatch(
            cityId: "lisbon",
            cityName: "Lisbon",
            cityFullName: "Lisbon, Portugal",
            cityCountry: "Portugal",
            cityImageUrl: "https://images.unsplash.com/photo-1585208798174-6cedd86e019a?auto=format&fit=crop&w=800&q=80",
            matchPercent: 82,
            rank: 2,
            comparison: [
                "Cost of Living": ComparisonMetric(matchScore: 7.0, currentScore: 2.5, delta: 4.5),
                "Environmental Quality": ComparisonMetric(matchScore: 7.0, currentScore: 6.0, delta: 1.0),
                "Leisure & Culture": ComparisonMetric(matchScore: 8.0, currentScore: 8.0, delta: 0.0),
                "Economy": ComparisonMetric(matchScore: 5.5, currentScore: 8.5, delta: -3.0),
                "Commute": ComparisonMetric(matchScore: 6.0, currentScore: 4.5, delta: 1.5),
            ],
            aiInsight: "Lisbon's warm climate and affordable lifestyle align perfectly with your preference for good weather and lower cost of living.",
            scores: ["Cost of Living": 7.0, "Environmental Quality": 7.0, "Leisure & Culture": 8.0, "Economy": 5.5, "Commute": 6.0]
        ),
        CityMatch(
            cityId: "montreal",
            cityName: "Montreal",
            cityFullName: "Montreal, Quebec, Canada",
            cityCountry: "Canada",
            cityImageUrl: "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?auto=format&fit=crop&w=800&q=80",
            matchPercent: 78,
            rank: 3,
            comparison: [
                "Cost of Living": ComparisonMetric(matchScore: 6.5, currentScore: 2.5, delta: 4.0),
                "Environmental Quality": ComparisonMetric(matchScore: 6.0, currentScore: 6.0, delta: 0.0),
                "Leisure & Culture": ComparisonMetric(matchScore: 9.0, currentScore: 8.0, delta: 1.0),
                "Economy": ComparisonMetric(matchScore: 6.5, currentScore: 8.5, delta: -2.0),
                "Commute": ComparisonMetric(matchScore: 6.5, currentScore: 4.5, delta: 2.0),
            ],
            aiInsight: "Montreal combines French-inspired culture with a moderate cost of living and a strong arts scene.",
            scores: ["Cost of Living": 6.5, "Environmental Quality": 6.0, "Leisure & Culture": 9.0, "Economy": 6.5, "Commute": 6.5]
        ),
    ]

    static let sampleReport = GenerateReportResponse(
        reportId: "preview-report-id",
        currentCity: CurrentCityInfo(
            id: "san-francisco",
            name: "San Francisco",
            scores: sampleScores
        ),
        matches: sampleMatches
    )
}

// MARK: - Preview Modifier

/// Wraps a view with a mock AppCoordinator environment for previews.
struct PreviewContainer<Content: View>: View {
    let coordinator: AppCoordinator
    @ViewBuilder let content: () -> Content

    init(
        coordinator: AppCoordinator? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.coordinator = coordinator ?? PreviewHelpers.makeCoordinator()
        self.content = content
    }

    var body: some View {
        content()
            .environment(coordinator)
            .preferredColorScheme(.dark)
    }
}
