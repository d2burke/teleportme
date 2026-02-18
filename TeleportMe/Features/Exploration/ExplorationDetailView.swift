import SwiftUI

// MARK: - Exploration Detail View

struct ExplorationDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    let exploration: Exploration

    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var showDeleteConfirmation = false
    @State private var vibeTagNames: [String: VibeTag] = [:]

    private var allCities: [City] {
        coordinator.cityService.allCities
    }

    private func city(for cityId: String) -> City? {
        allCities.first { $0.id == cityId }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xl) {
                // Header with title
                headerSection

                // Baseline city info
                if let cityId = exploration.baselineCityId,
                   let city = city(for: cityId) {
                    baselineSection(city: city)
                }

                // Compass signals (for compass explorations)
                if let compassVibes = exploration.compassVibes, !compassVibes.isEmpty {
                    compassSection(vibes: compassVibes, constraints: exploration.compassConstraints)
                }

                // Vibes used (for legacy vibes-type explorations)
                if exploration.startType == .vibes,
                   exploration.compassVibes == nil,
                   let vibeTags = exploration.vibeTags, !vibeTags.isEmpty {
                    vibesSection(vibeIds: vibeTags)
                }

                // Matches / Results
                if !exploration.results.isEmpty {
                    resultsSection
                }

                // AI Summary
                if let summary = exploration.aiSummary, !summary.isEmpty {
                    aiSummarySection(summary)
                }

                // Preferences used
                if let prefs = exploration.preferences {
                    preferencesSection(prefs)
                }

                // Actions
                actionsSection
            }
            .padding(.bottom, TeleportTheme.Spacing.xxl)
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: City.self) { city in
            CityDetailView(city: city)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        analytics.trackButtonTap("rename", screen: "exploration_detail", properties: ["exploration_id": exploration.id ?? ""])
                        editedTitle = exploration.title
                        isEditing = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        analytics.trackButtonTap("delete", screen: "exploration_detail", properties: ["exploration_id": exploration.id ?? ""])
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }
        }
        .alert("Rename Exploration", isPresented: $isEditing) {
            TextField("Title", text: $editedTitle)
            Button("Save") {
                guard let id = exploration.id,
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
                guard let id = exploration.id,
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
            Text("This will permanently remove \"\(exploration.title)\" and its results.")
        }
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("exploration_detail", properties: [
                "exploration_id": exploration.id ?? ""
            ])
            editedTitle = exploration.title
        }
        .task {
            // Load vibe tag names for display
            if exploration.startType == .vibes,
               let vibeTags = exploration.vibeTags, !vibeTags.isEmpty {
                do {
                    let tags = try await coordinator.explorationService.fetchVibeTags()
                    var map: [String: VibeTag] = [:]
                    for tag in tags {
                        map[tag.id] = tag
                    }
                    vibeTagNames = map
                } catch {
                    print("Failed to load vibe tag names: \(error)")
                }
            }
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("exploration_detail", durationMs: ms, exitType: "back", properties: [
                "exploration_id": exploration.id ?? ""
            ])
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            // Start type badge
            HStack(spacing: TeleportTheme.Spacing.xs) {
                Image(systemName: startTypeIcon)
                    .font(.system(size: 12))
                Text(startTypeLabel)
                    .font(TeleportTheme.Typography.sectionHeader(11))
            }
            .foregroundStyle(TeleportTheme.Colors.accent)
            .padding(.horizontal, TeleportTheme.Spacing.sm)
            .padding(.vertical, 4)
            .background(TeleportTheme.Colors.accent.opacity(0.15))
            .clipShape(Capsule())

            Text(exploration.title)
                .font(TeleportTheme.Typography.heroTitle(28))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)

            HStack(spacing: TeleportTheme.Spacing.md) {
                if let date = exploration.createdAt {
                    Label(date.formatted(.dateTime.month(.abbreviated).day().year()), systemImage: "calendar")
                        .font(TeleportTheme.Typography.caption(13))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }

                Text("\(exploration.results.count) cities found")
                    .font(TeleportTheme.Typography.caption(13))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
        .padding(.top, TeleportTheme.Spacing.md)
    }

    private var startTypeIcon: String {
        if exploration.compassVibes != nil { return "safari" }
        switch exploration.startType {
        case .cityILove: return "heart.fill"
        case .vibes: return "safari"
        case .myWords: return "text.quote"
        }
    }

    private var startTypeLabel: String {
        if exploration.compassVibes != nil { return "Compass" }
        switch exploration.startType {
        case .cityILove: return "City I Love"
        case .vibes: return "Compass"
        case .myWords: return "My Own Words"
        }
    }

    // MARK: - Compass

    private func compassSection(vibes: [String: Double], constraints: TripConstraints?) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            // Heading badge
            let heading = HeadingEngine.heading(fromRaw: vibes)
            HStack(spacing: TeleportTheme.Spacing.sm) {
                Text(heading.emoji)
                    .font(.system(size: 22))
                Text(heading.name)
                    .font(TeleportTheme.Typography.cardTitle(16))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)

            // Active signals
            FlowLayout(spacing: TeleportTheme.Spacing.xs) {
                ForEach(vibes.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    if value > 0, let signal = CompassSignal(rawValue: key) {
                        HStack(spacing: 4) {
                            Text(signal.emoji)
                                .font(.system(size: 11))
                            Text(signal.shortLabel)
                                .font(TeleportTheme.Typography.caption(11))
                                .foregroundStyle(signal.color)

                            // Intensity dots
                            HStack(spacing: 2) {
                                ForEach(1...3, id: \.self) { i in
                                    Circle()
                                        .fill(Double(i) <= value ? signal.color : signal.color.opacity(0.2))
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(signal.color.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)

            // Constraints
            if let constraints, constraints.hasAny {
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    if let travel = constraints.travelDistance {
                        constraintPill(emoji: travel.emoji, label: travel.label)
                    }
                    if let safety = constraints.safetyComfort {
                        constraintPill(emoji: safety.emoji, label: safety.label)
                    }
                    if let budget = constraints.budgetVibe {
                        constraintPill(emoji: budget.emoji, label: budget.label)
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
        }
    }

    private func constraintPill(emoji: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 10))
            Text(label)
                .font(TeleportTheme.Typography.caption(10))
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(TeleportTheme.Colors.surface)
        .clipShape(Capsule())
        .overlay {
            Capsule().strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
        }
    }

    // MARK: - Vibes

    private func vibesSection(vibeIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            SectionHeader(title: "Vibes")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            FlowLayout(spacing: TeleportTheme.Spacing.sm) {
                ForEach(vibeIds, id: \.self) { vibeId in
                    if let tag = vibeTagNames[vibeId] {
                        TrendingChip(
                            title: "\(tag.emoji ?? "") \(tag.name)",
                            isSelected: true
                        ) {}
                        .disabled(true)
                    }
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - Baseline City

    private func baselineSection(city: City) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            Text("Based on")
                .font(TeleportTheme.Typography.caption(12))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                .tracking(1)

            NavigationLink(value: city) {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Rectangle().fill(TeleportTheme.Colors.surfaceElevated)
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(city.name)
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        Text(city.country)
                            .font(TeleportTheme.Typography.caption(13))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }
                .padding(TeleportTheme.Spacing.md)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Results")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            VStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(exploration.results) { match in
                    if let city = city(for: match.cityId) {
                        NavigationLink(value: city) {
                            resultCard(match: match)
                        }
                        .buttonStyle(.plain)
                    } else {
                        resultCard(match: match)
                    }
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    private func resultCard(match: CityMatch) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    // City image
                    AsyncImage(url: URL(string: match.cityImageUrl ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Rectangle()
                                .fill(TeleportTheme.Colors.surfaceElevated)
                                .overlay {
                                    Image(systemName: "building.2")
                                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                }
                        }
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        HStack {
                            Text("#\(match.rank)")
                                .font(TeleportTheme.Typography.sectionHeader(12))
                                .foregroundStyle(TeleportTheme.Colors.accent)

                            Text(match.cityName)
                                .font(TeleportTheme.Typography.cardTitle(17))
                                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        }

                        Text(match.cityCountry)
                            .font(TeleportTheme.Typography.body(14))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }

                    Spacer()

                    // Match percent
                    VStack(spacing: 2) {
                        Text("\(match.matchPercent)%")
                            .font(TeleportTheme.Typography.title(20))
                            .foregroundStyle(TeleportTheme.Colors.accent)
                        Text("match")
                            .font(TeleportTheme.Typography.caption(10))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    }
                }

                // AI Insight
                if let insight = match.aiInsight, !insight.isEmpty {
                    Text(insight)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .lineLimit(3)
                }
            }
        }
    }

    // MARK: - AI Summary

    private func aiSummarySection(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            SectionHeader(title: "AI Insights")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            CardView {
                HStack(alignment: .top, spacing: TeleportTheme.Spacing.md) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(TeleportTheme.Colors.accent)

                    Text(summary)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - Preferences

    private func preferencesSection(_ prefs: ReportPreferences) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            SectionHeader(title: "Preferences Used")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            CardView {
                VStack(spacing: TeleportTheme.Spacing.sm) {
                    prefRow(icon: "banknote", title: "Cost of Living", value: prefs.cost)
                    prefRow(icon: "thermometer.sun", title: "Climate", value: prefs.climate)
                    prefRow(icon: "theatermasks", title: "Culture", value: prefs.culture)
                    prefRow(icon: "briefcase", title: "Job Market", value: prefs.jobMarket)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    private func prefRow(icon: String, title: String, value: Double) -> some View {
        HStack(spacing: TeleportTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(TeleportTheme.Colors.accent)
                .frame(width: 20)
            Text(title)
                .font(TeleportTheme.Typography.body(14))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
            Spacer()
            Text(String(format: "%.0f/10", value))
                .font(TeleportTheme.Typography.cardTitle(14))
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: TeleportTheme.Spacing.md) {
            // New exploration with same settings
            TeleportButton(
                title: "Explore Again",
                icon: "arrow.clockwise",
                style: .secondary
            ) {
                analytics.trackButtonTap("explore_again", screen: "exploration_detail", properties: ["exploration_id": exploration.id ?? ""])
                coordinator.showNewExplorationModal = true
            }
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
    }
}

// MARK: - Preview

#Preview("Exploration Detail") {
    PreviewContainer {
        NavigationStack {
            ExplorationDetailView(
                exploration: Exploration(
                    id: "preview-1",
                    userId: "user-1",
                    title: "Beach Vibes Trip",
                    startType: .cityILove,
                    baselineCityId: "lisbon",
                    preferences: ReportPreferences(cost: 7, climate: 9, culture: 8, jobMarket: 5),
                    results: [],
                    aiSummary: "Based on your love for Lisbon's warm climate and rich culture, we found several cities that share similar vibes.",
                    vibeTags: nil,
                    freeText: nil,
                    compassVibes: nil,
                    compassConstraints: nil,
                    headingName: nil,
                    headingEmoji: nil,
                    headingColor: nil,
                    headingTopSignals: nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            )
        }
    }
}
