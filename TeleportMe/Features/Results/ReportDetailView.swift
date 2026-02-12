import SwiftUI

// MARK: - Report Detail View

/// Displays a past CityReport with its matches, comparisons, and AI insights.
/// Reuses the same visual components as RecommendationsView but is driven
/// directly from a `CityReport` rather than from `reportService.currentReport`.
struct ReportDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator

    let report: CityReport

    @State private var showShareSheet = false

    private var matches: [CityMatch] {
        report.results
    }

    private var currentCityName: String {
        guard let cityId = report.currentCityId else { return "Your City" }
        return coordinator.cityService.allCities.first { $0.id == cityId }?.name ?? cityId
    }

    private var shareText: String {
        var text = "My TeleportMe city report\n\n"
        for match in matches {
            text += "#\(match.rank) \(match.cityName) — \(match.matchPercent)% match\n"
        }
        if let summary = report.aiSummary {
            text += "\n\(summary)"
        }
        return text
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.lg) {
                headerSection
                matchesCarousel
                comparisonSection
                aiSummarySection
            }
            .padding(.bottom, 100)
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("REPORT")
                    .font(TeleportTheme.Typography.sectionHeader(12))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .tracking(1.5)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(text: shareText)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
            // Date
            if let date = report.createdAt {
                Text(formattedDate(date))
                    .font(TeleportTheme.Typography.caption())
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }

            Text("City\n")
                .font(TeleportTheme.Typography.title(32))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
            +
            Text("Recommendations")
                .font(TeleportTheme.Typography.title(32))
                .foregroundStyle(TeleportTheme.Colors.accent)

            HStack(spacing: TeleportTheme.Spacing.md) {
                Label("\(matches.count) matches", systemImage: "heart.circle")
                    .font(TeleportTheme.Typography.body(14))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)

                Label(currentCityName, systemImage: "mappin.circle")
                    .font(TeleportTheme.Typography.body(14))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
        .padding(.top, TeleportTheme.Spacing.sm)
    }

    // MARK: - Matches Carousel

    private var matchesCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(matches) { match in
                    ZStack(alignment: .topTrailing) {
                        CityHeroImage(
                            imageURL: match.cityImageUrl,
                            cityName: match.cityName,
                            subtitle: match.cityCountry,
                            height: 280,
                            matchPercent: match.matchPercent,
                            rank: match.rank
                        )
                        .frame(width: UIScreen.main.bounds.width - 80)

                        saveButton(cityId: match.cityId)
                            .padding(.top, 72)
                            .padding(.trailing, TeleportTheme.Spacing.sm)
                    }
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - Comparison Section

    @ViewBuilder
    private var comparisonSection: some View {
        if let topMatch = matches.first, let comparison = topMatch.comparison, !comparison.isEmpty {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                HStack {
                    Text("The Comparison")
                        .font(TeleportTheme.Typography.title(22))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Spacer()

                    Text("V. \(currentCityName.uppercased())")
                        .font(TeleportTheme.Typography.sectionHeader(11))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }

                ForEach(Array(comparison.keys.sorted()), id: \.self) { category in
                    if let metric = comparison[category] {
                        ComparisonCard(
                            category: category,
                            matchScore: metric.matchScore,
                            currentScore: metric.currentScore,
                            delta: metric.delta,
                            matchCityName: topMatch.cityName,
                            currentCityName: currentCityName
                        )
                    }
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - AI Summary / Insights

    @ViewBuilder
    private var aiSummarySection: some View {
        // Report-level AI summary
        if let summary = report.aiSummary, !summary.isEmpty {
            CardView {
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                    HStack(spacing: TeleportTheme.Spacing.sm) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(TeleportTheme.Colors.accent)
                        Text("AI Summary")
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    }

                    Text(summary)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }

        // Per-match AI insights
        ForEach(matches) { match in
            if let insight = match.aiInsight, !insight.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                        HStack(spacing: TeleportTheme.Spacing.sm) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(TeleportTheme.Colors.accent)
                            Text("\(match.cityName) Insight")
                                .font(TeleportTheme.Typography.cardTitle())
                                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        }

                        Text(insight)
                            .font(TeleportTheme.Typography.body(14))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
        }
    }

    // MARK: - Save Button

    private func saveButton(cityId: String) -> some View {
        let isSaved = coordinator.savedCitiesService.isSaved(cityId: cityId)
        return Button {
            Task {
                await coordinator.savedCitiesService.toggleSave(cityId: cityId)
            }
        } label: {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isSaved ? TeleportTheme.Colors.accent : TeleportTheme.Colors.textSecondary)
                .frame(width: 32, height: 32)
                .background(TeleportTheme.Colors.background.opacity(0.6))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Report Detail") {
    NavigationStack {
        ReportDetailView(report: CityReport(
            id: "preview-1",
            userId: "user-1",
            currentCityId: "san-francisco",
            preferences: ReportPreferences(cost: 5, climate: 7, culture: 8, jobMarket: 6),
            results: PreviewHelpers.sampleMatches,
            aiSummary: "Based on your preferences, Berlin stands out as an exceptional match with significantly lower cost of living while maintaining a vibrant cultural scene.",
            createdAt: Date()
        ))
    }
    .environment(PreviewHelpers.makeCoordinatorWithReport())
    .preferredColorScheme(.dark)
}
