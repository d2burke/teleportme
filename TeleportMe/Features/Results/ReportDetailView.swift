import SwiftUI

// MARK: - Report Detail View

/// Unified results view that displays city recommendations from any source:
/// - Post-onboarding generation (RecommendationsView wraps this)
/// - Post-new-exploration generation (ExplorationResultsStepView wraps this)
/// - Past explorations from Discover tab
/// - Legacy CityReport history
struct ReportDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    let viewModel: ResultsViewModel

    /// When true, shows bottom CTA bar ("Let's Go" / "Done") instead of standard back nav.
    var isPostGeneration: Bool = false

    /// Called when the user taps "Done" or "Let's Go" in post-generation mode.
    var onDone: (() -> Void)?

    @State private var selectedMatchIndex = 0
    @State private var showShareSheet = false
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var showDeleteConfirmation = false
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    private var matches: [CityMatch] {
        viewModel.matches
    }

    private var resolvedCurrentCityName: String {
        if let name = viewModel.currentCityName { return name }
        guard let cityId = viewModel.currentCityId else { return "Your City" }
        return coordinator.cityService.allCities.first { $0.id == cityId }?.name ?? cityId
    }

    private var hasBaselineCity: Bool {
        viewModel.currentCityId != nil
    }

    private var screenName: String {
        switch viewModel.source {
        case .onboarding: "recommendations"
        case .newExploration: "exploration_results"
        case .pastExploration: "exploration_detail"
        case .legacyReport: "report_detail"
        }
    }

    private var shareText: String {
        var text = "My TeleportMe city recommendations\n\n"
        for match in matches {
            text += "#\(match.rank) \(match.cityName) — \(match.matchPercent)% match\n"
        }
        if let summary = viewModel.aiSummary {
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

                // Only show comparison when there's a baseline city
                if hasBaselineCity {
                    comparisonSection
                }

                aiInsightsSection
            }
            .padding(.bottom, isPostGeneration ? 100 : TeleportTheme.Spacing.xxl)
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: City.self) { city in
            CityDetailView(city: city)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(isPostGeneration ? "RECOMMENDATIONS" : "REPORT")
                    .font(TeleportTheme.Typography.sectionHeader(12))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .tracking(1.5)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    // Exploration management menu (rename/delete)
                    if viewModel.exploration != nil {
                        explorationMenu
                    }

                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(text: shareText)
        }
        .overlay(alignment: .bottom) {
            if isPostGeneration {
                postGenerationCTA
            }
        }
        .alert("Rename Exploration", isPresented: $isEditing) {
            TextField("Title", text: $editedTitle)
            Button("Save") {
                guard let exploration = viewModel.exploration,
                      let id = exploration.id,
                      let userId = coordinator.currentUserId else { return }
                Task {
                    await coordinator.explorationService.renameExploration(
                        id: id, newTitle: editedTitle, userId: userId
                    )
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Delete Exploration?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                guard let exploration = viewModel.exploration,
                      let id = exploration.id,
                      let userId = coordinator.currentUserId else { return }
                Task {
                    await coordinator.explorationService.deleteExploration(
                        id: id, userId: userId
                    )
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove \"\(viewModel.title)\" and its results.")
        }
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView(screenName)
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit(screenName, durationMs: ms, exitType: isPostGeneration ? "completed" : "back")
        }
    }

    // MARK: - Exploration Menu

    @ViewBuilder
    private var explorationMenu: some View {
        Menu {
            Button {
                editedTitle = viewModel.title
                isEditing = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
            // Date (for saved explorations/reports)
            if let date = viewModel.createdAt {
                Text(formattedDate(date))
                    .font(TeleportTheme.Typography.caption())
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }

            if viewModel.source == .pastExploration {
                // Show exploration title prominently
                Text(viewModel.title)
                    .font(TeleportTheme.Typography.heroTitle(28))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
            } else {
                Text("Top City\n")
                    .font(TeleportTheme.Typography.title(32))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                +
                Text("Recommendations")
                    .font(TeleportTheme.Typography.title(32))
                    .foregroundStyle(TeleportTheme.Colors.accent)
            }

            HStack(spacing: TeleportTheme.Spacing.md) {
                Label("\(matches.count) matches", systemImage: "heart.circle")
                    .font(TeleportTheme.Typography.body(14))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)

                if hasBaselineCity {
                    Label(resolvedCurrentCityName, systemImage: "mappin.circle")
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }

            // Compass heading badge (for compass explorations)
            if let exploration = viewModel.exploration,
               let compassVibes = exploration.compassVibes, !compassVibes.isEmpty {
                let heading = HeadingEngine.heading(fromRaw: compassVibes)
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    Text(heading.emoji)
                        .font(.system(size: 18))
                    Text(heading.name)
                        .font(TeleportTheme.Typography.cardTitle(14))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                }
                .padding(.top, TeleportTheme.Spacing.xs)
            }
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
        .padding(.top, TeleportTheme.Spacing.sm)
    }

    // MARK: - Matches Carousel

    private var matchesCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(Array(matches.enumerated()), id: \.1.id) { index, match in
                    ZStack(alignment: .topTrailing) {
                        CityHeroImage(
                            imageURL: match.cityImageUrl,
                            cityName: match.cityName,
                            subtitle: match.cityCountry,
                            height: isPostGeneration ? 320 : 280,
                            matchPercent: match.matchPercent,
                            rank: match.rank
                        )
                        .frame(width: UIScreen.main.bounds.width - 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: TeleportTheme.Radius.large)
                                .strokeBorder(
                                    selectedMatchIndex == index
                                        ? TeleportTheme.Colors.accent
                                        : .clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            analytics.track("match_card_tapped", screen: screenName, properties: [
                                "city_id": match.cityId,
                                "rank": String(match.rank),
                                "match_percent": String(match.matchPercent)
                            ])
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMatchIndex = index
                            }
                        }

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
        if let selectedMatch = matches[safe: selectedMatchIndex] ?? matches.first,
           let comparison = selectedMatch.comparison, !comparison.isEmpty {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                HStack {
                    Text("The Comparison")
                        .font(TeleportTheme.Typography.title(22))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Spacer()

                    Text("V. \(resolvedCurrentCityName.uppercased())")
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
                            matchCityName: selectedMatch.cityName,
                            currentCityName: resolvedCurrentCityName
                        )
                    }
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - AI Insights

    @ViewBuilder
    private var aiInsightsSection: some View {
        // Report-level AI summary
        if let summary = viewModel.aiSummary, !summary.isEmpty {
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

        // Per-match AI insights (show for selected match when in post-generation mode,
        // or all matches for browsing mode)
        if isPostGeneration {
            if let selectedMatch = matches[safe: selectedMatchIndex] ?? matches.first,
               let insight = selectedMatch.aiInsight, !insight.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                        HStack(spacing: TeleportTheme.Spacing.sm) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(TeleportTheme.Colors.accent)
                            Text("Expert Insights")
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
        } else {
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
    }

    // MARK: - Post-Generation CTA

    private var postGenerationCTA: some View {
        HStack(spacing: TeleportTheme.Spacing.md) {
            TeleportButton(title: "Share", icon: "square.and.arrow.up", style: .secondary) {
                analytics.trackButtonTap("share", screen: screenName, properties: [
                    "match_count": String(matches.count)
                ])
                showShareSheet = true
            }

            TeleportButton(title: viewModel.source == .onboarding ? "Let's Go" : "Done") {
                analytics.trackButtonTap("done", screen: screenName)
                onDone?()
            }
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
        .padding(.bottom, TeleportTheme.Spacing.lg)
        .background(
            LinearGradient(
                colors: [TeleportTheme.Colors.background.opacity(0), TeleportTheme.Colors.background],
                startPoint: .top,
                endPoint: .center
            )
        )
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

#Preview("Report Detail - From Report") {
    NavigationStack {
        ReportDetailView(
            viewModel: ResultsViewModel(
                from: CityReport(
                    id: "preview-1",
                    userId: "user-1",
                    currentCityId: "san-francisco",
                    preferences: ReportPreferences(cost: 5, climate: 7, culture: 8, jobMarket: 6),
                    results: PreviewHelpers.sampleMatches,
                    aiSummary: "Based on your preferences, Berlin stands out as an exceptional match.",
                    createdAt: Date()
                )
            )
        )
    }
    .environment(PreviewHelpers.makeCoordinatorWithReport())
    .preferredColorScheme(.dark)
}

#Preview("Report Detail - Post Generation") {
    NavigationStack {
        ReportDetailView(
            viewModel: ResultsViewModel(
                from: GenerateReportResponse(
                    reportId: "preview-1",
                    currentCity: nil,
                    matches: PreviewHelpers.sampleMatches
                ),
                source: .onboarding
            ),
            isPostGeneration: true,
            onDone: {}
        )
    }
    .environment(PreviewHelpers.makeCoordinatorWithReport())
    .preferredColorScheme(.dark)
}
