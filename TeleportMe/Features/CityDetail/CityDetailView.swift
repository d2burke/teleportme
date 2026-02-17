import SwiftUI

// MARK: - City Detail View

struct CityDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    let city: City

    @State private var cityWithScores: CityWithScores?
    @State private var similarCities: [CityService.SimilarCity] = []
    @State private var insights: CityInsights?
    @State private var isLoadingInsights = false
    @State private var isLoading = true

    // All scores sorted for pivot links
    private var allScores: [(category: String, scores: [String: Double])] {
        guard let cws = cityWithScores else { return [] }
        return cws.scores.map { ($0.key, [:]) }
    }

    private var isSaved: Bool {
        coordinator.savedCitiesService.isSaved(cityId: city.id)
    }

    private var match: CityMatch? {
        coordinator.reportService.currentReport?.matches.first { $0.cityId == city.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.lg) {
                // Hero
                heroSection

                // Match badge (if this city is in the user's report)
                if let match {
                    matchBadge(match)
                        .padding(.horizontal, TeleportTheme.Spacing.lg)
                }

                // Summary
                if let summary = city.summary, !summary.isEmpty {
                    summarySection(summary)
                }

                // Known For & Concerns
                if let insights {
                    insightsSection(insights)
                } else if isLoadingInsights {
                    insightsLoadingSection
                }

                // Scores
                if let cws = cityWithScores {
                    scoresSection(cws)
                } else if isLoading {
                    ProgressView()
                        .tint(TeleportTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TeleportTheme.Spacing.xl)
                }

                // Similar Cities
                if !similarCities.isEmpty {
                    similarCitiesSection
                }

                Spacer(minLength: TeleportTheme.Spacing.xxl)
            }
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let action = isSaved ? "unsave" : "save"
                    analytics.trackButtonTap(action, screen: "city_detail", properties: ["city_id": city.id])
                    if !isSaved {
                        analytics.track("city_saved", screen: "city_detail", properties: ["city_id": city.id])
                    } else {
                        analytics.track("city_unsaved", screen: "city_detail", properties: ["city_id": city.id])
                    }
                    Task { await coordinator.savedCitiesService.toggleSave(cityId: city.id) }
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? TeleportTheme.Colors.accent : .white)
                        .contentTransition(.symbolEffect(.replace))
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: isSaved)
            }
        }
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("city_detail", properties: [
                "city_id": city.id, "city_name": city.name
            ])
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("city_detail", durationMs: ms, exitType: "back", properties: ["city_id": city.id])
        }
        .task {
            await loadScores()
        }
    }

    // MARK: - Load Scores

    private func loadScores() async {
        isLoading = true
        isLoadingInsights = true
        let start = Date()
        defer { isLoading = false }
        cityWithScores = await coordinator.cityService.getCityWithScores(cityId: city.id)

        // Compute similar cities from the in-memory score cache
        similarCities = coordinator.cityService.similarCities(to: city.id, limit: 8)

        let ms = Int(Date().timeIntervalSince(start) * 1000)
        analytics.track("city_detail_loaded", screen: "city_detail", properties: [
            "city_id": city.id, "duration_ms": String(ms),
            "similar_count": String(similarCities.count)
        ])

        // Fetch insights (non-blocking — loads after scores appear)
        Task {
            insights = await coordinator.cityService.getCityInsights(cityId: city.id)
            isLoadingInsights = false
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        CityHeroImage(
            imageURL: city.imageUrl,
            cityName: city.name,
            subtitle: city.country,
            height: 300,
            matchPercent: match?.matchPercent
        )
    }

    // MARK: - Match Badge

    private func matchBadge(_ match: CityMatch) -> some View {
        HStack(spacing: TeleportTheme.Spacing.sm) {
            Image(systemName: "star.fill")
                .foregroundStyle(TeleportTheme.Colors.accent)

            Text("#\(match.rank) Match · \(match.matchPercent)%")
                .font(TeleportTheme.Typography.cardTitle())
                .foregroundStyle(TeleportTheme.Colors.textPrimary)

            Spacer()
        }
        .padding(TeleportTheme.Spacing.md)
        .background(TeleportTheme.Colors.accentSubtle)
        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
    }

    // MARK: - Summary

    private func summarySection(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            SectionHeader(title: "About")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            Text(summary)
                .font(TeleportTheme.Typography.body())
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - Scores Section

    private func scoresSection(_ cws: CityWithScores) -> some View {
        let categories = scoreCategories(from: cws)

        return VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "City Scores")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            LazyVStack(spacing: TeleportTheme.Spacing.sm) {
                ForEach(categories, id: \.category) { item in
                    ScoreCategoryRow(
                        category: item.category,
                        score: item.score,
                        lowerCity: item.lowerCity,
                        higherCity: item.higherCity,
                        color: TeleportTheme.Colors.forCategory(item.category)
                    )
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)

            // AI Insight
            if let insight = match?.aiInsight, !insight.isEmpty {
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                    SectionHeader(title: "AI Insight")
                        .padding(.horizontal, TeleportTheme.Spacing.lg)

                    CardView {
                        HStack(alignment: .top, spacing: TeleportTheme.Spacing.sm) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(TeleportTheme.Colors.accent)
                                .font(.system(size: 16))

                            Text(insight)
                                .font(TeleportTheme.Typography.body(14))
                                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
            }
        }
    }

    // MARK: - Insights Section (Known For & Concerns)

    private func insightsSection(_ insights: CityInsights) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.lg) {
            // Known For
            if !insights.knownFor.isEmpty {
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                    SectionHeader(title: "Known For")
                        .padding(.horizontal, TeleportTheme.Spacing.lg)

                    FlowLayout(spacing: TeleportTheme.Spacing.sm) {
                        ForEach(insights.knownFor, id: \.self) { item in
                            insightChip(item, icon: "checkmark.circle.fill", color: .green)
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
            }

            // Concerns
            if !insights.concerns.isEmpty {
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                    SectionHeader(title: "Concerns")
                        .padding(.horizontal, TeleportTheme.Spacing.lg)

                    FlowLayout(spacing: TeleportTheme.Spacing.sm) {
                        ForEach(insights.concerns, id: \.self) { item in
                            insightChip(item, icon: "exclamationmark.triangle.fill", color: .orange)
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
            }
        }
    }

    private func insightChip(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: TeleportTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color.opacity(0.8))

            Text(text)
                .font(TeleportTheme.Typography.caption(13))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
        }
        .padding(.horizontal, TeleportTheme.Spacing.md)
        .padding(.vertical, TeleportTheme.Spacing.sm)
        .background(TeleportTheme.Colors.surface)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
        }
    }

    private var insightsLoadingSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            SectionHeader(title: "Known For")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            HStack(spacing: TeleportTheme.Spacing.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(TeleportTheme.Colors.surface)
                        .frame(width: 120, height: 32)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .redacted(reason: .placeholder)
        }
    }

    // MARK: - Similar Cities Section

    private var similarCitiesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Similar Cities")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    ForEach(similarCities, id: \.city.id) { similar in
                        NavigationLink(value: similar.city) {
                            similarCityCard(similar)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
        }
    }

    private func similarCityCard(_ similar: CityService.SimilarCity) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // City image
            AsyncImage(url: URL(string: similar.city.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle().fill(TeleportTheme.Colors.surfaceElevated)
                default:
                    Rectangle()
                        .fill(TeleportTheme.Colors.surfaceElevated)
                        .overlay {
                            ProgressView()
                                .tint(TeleportTheme.Colors.accent)
                        }
                }
            }
            .frame(width: 160, height: 110)
            .clipped()

            // City info + comparison tag
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                Text(similar.city.name)
                    .font(TeleportTheme.Typography.cardTitle(15))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(similar.city.country)
                    .font(TeleportTheme.Typography.caption(12))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .lineLimit(1)

                Text(similar.comparisonTag)
                    .font(TeleportTheme.Typography.caption(11))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                    .lineLimit(1)
            }
            .padding(TeleportTheme.Spacing.sm)
        }
        .frame(width: 160, height: 200)
        .background(TeleportTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.card))
    }

    // MARK: - Score Category Data

    private struct ScoreCategoryData {
        let category: String
        let score: Double
        let lowerCity: City?
        let higherCity: City?
    }

    /// For each score category of this city, find one city that scores lower and one that scores higher.
    private func scoreCategories(from cws: CityWithScores) -> [ScoreCategoryData] {
        let sortedCategories = cws.scores.sorted { $0.key < $1.key }

        return sortedCategories.map { (category, score) in
            let pivots = findPivotCities(
                for: category,
                currentScore: score,
                currentCityId: city.id
            )

            return ScoreCategoryData(
                category: category,
                score: score,
                lowerCity: pivots.lower,
                higherCity: pivots.higher
            )
        }
    }

    /// Finds the closest city scoring lower and higher than `currentScore` in the given `category`.
    /// Uses the CityService's in-memory score cache.
    private func findPivotCities(
        for category: String,
        currentScore: Double,
        currentCityId: String
    ) -> (lower: City?, higher: City?) {
        let allCities = coordinator.cityService.allCities

        var bestLower: (city: City, score: Double)? = nil
        var bestHigher: (city: City, score: Double)? = nil

        for otherCity in allCities where otherCity.id != currentCityId {
            // Access the score cache via the cityService internal scoreCache
            // We'll use a helper on CityService to check cached scores
            guard let otherScore = coordinator.cityService.cachedScore(
                cityId: otherCity.id,
                category: category
            ) else { continue }

            if otherScore < currentScore {
                if bestLower == nil || otherScore > bestLower!.score {
                    bestLower = (otherCity, otherScore)
                }
            } else if otherScore > currentScore {
                if bestHigher == nil || otherScore < bestHigher!.score {
                    bestHigher = (otherCity, otherScore)
                }
            }
        }

        return (bestLower?.city, bestHigher?.city)
    }
}

// MARK: - Score Category Row

private struct ScoreCategoryRow: View {
    let category: String
    let score: Double
    let lowerCity: City?
    let higherCity: City?
    let color: Color

    @State private var showInfo = false

    private var explainer: MetricExplainer? {
        MetricExplainer.forCategory(category)
    }

    private func displayName(for category: String) -> String {
        switch category {
        case "Cost of Living": return "Cost of Living"
        case "Environmental Quality": return "Climate"
        case "Leisure & Culture": return "Culture"
        case "Economy": return "Jobs"
        case "Commute": return "Mobility"
        default: return category
        }
    }

    private func icon(for category: String) -> String {
        switch category {
        case "Cost of Living", "Housing", "Taxation": return "banknote"
        case "Environmental Quality": return "sun.max"
        case "Leisure & Culture", "Tolerance": return "theatermasks"
        case "Economy", "Startups", "Venture Capital": return "briefcase"
        case "Commute", "Travel Connectivity": return "tram"
        case "Safety": return "shield"
        case "Healthcare": return "heart.text.square"
        case "Education": return "book"
        case "Outdoors": return "leaf"
        case "Internet Access": return "wifi"
        case "Business Freedom": return "building.2"
        default: return "chart.bar"
        }
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                // Header
                HStack {
                    Image(systemName: icon(for: category))
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                        .frame(width: 32, height: 32)
                        .background(color.opacity(0.15))
                        .clipShape(Circle())

                    Text(displayName(for: category))
                        .font(TeleportTheme.Typography.cardTitle(15))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Spacer()

                    if explainer != nil {
                        Button {
                            if !showInfo {
                                AnalyticsService.shared.track("metric_info_tapped", screen: "city_detail", properties: [
                                    "category": category
                                ])
                            }
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showInfo.toggle()
                            }
                        } label: {
                            Image(systemName: showInfo ? "xmark.circle.fill" : "info.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(
                                    showInfo
                                        ? TeleportTheme.Colors.textSecondary
                                        : TeleportTheme.Colors.textTertiary
                                )
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                    }

                    Text(String(format: "%.1f", score))
                        .font(TeleportTheme.Typography.scoreValue(22))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Text("/ 10")
                        .font(TeleportTheme.Typography.caption(11))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }

                // Expandable info
                if showInfo, let explainer {
                    Text(explainer.summary)
                        .font(TeleportTheme.Typography.caption(12))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(TeleportTheme.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(TeleportTheme.Colors.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                            removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                        ))
                }

                // Score bar
                ScoreBar(
                    label: "",
                    score: score,
                    maxScore: 10,
                    color: color,
                    showValue: false,
                    height: 6
                )

                // Pivot links
                if lowerCity != nil || higherCity != nil {
                    Divider()
                        .overlay(TeleportTheme.Colors.border)

                    HStack(spacing: TeleportTheme.Spacing.lg) {
                        if let lower = lowerCity {
                            PivotLink(
                                label: "Lower",
                                cityName: lower.name,
                                icon: "arrow.down.right",
                                color: .red.opacity(0.6),
                                city: lower
                            )
                        }

                        if lowerCity != nil && higherCity != nil {
                            Spacer()
                        }

                        if let higher = higherCity {
                            PivotLink(
                                label: "Higher",
                                cityName: higher.name,
                                icon: "arrow.up.right",
                                color: .green.opacity(0.8),
                                city: higher
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Pivot Link (navigates to another city)

private struct PivotLink: View {
    let label: String
    let cityName: String
    let icon: String
    let color: Color
    let city: City

    var body: some View {
        NavigationLink(value: city) {
            HStack(spacing: TeleportTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 1) {
                    Text(label.uppercased())
                        .font(TeleportTheme.Typography.sectionHeader(9))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)

                    Text(cityName)
                        .font(TeleportTheme.Typography.caption(13))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("City Detail") {
    NavigationStack {
        CityDetailView(city: City(
            id: "denver",
            name: "Denver",
            fullName: "Denver, Colorado",
            country: "United States",
            continent: "North America",
            latitude: 39.7392,
            longitude: -104.9903,
            population: 715522,
            teleportCityScore: 68.5,
            summary: "Denver is a vibrant city at the base of the Rocky Mountains, known for its outdoor lifestyle and growing tech scene.",
            imageUrl: "https://images.unsplash.com/photo-1619856699906-09e1f4ef9c36?auto=format&fit=crop&w=800&q=80",
            createdAt: nil,
            updatedAt: nil
        ))
    }
    .preferredColorScheme(.dark)
}
