import SwiftUI

// MARK: - Sort Option

enum CitySortOption: String, CaseIterable, Identifiable {
    case name = "A–Z"
    case rating = "Rating"
    case safety = "Safety"
    case cost = "Cost"
    case warmClimate = "Warm"
    case coolClimate = "Cool"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .name: return "textformat.abc"
        case .rating: return "star.fill"
        case .safety: return "shield.checkered"
        case .cost: return "banknote"
        case .warmClimate: return "sun.max.fill"
        case .coolClimate: return "snowflake"
        }
    }

    var color: Color {
        switch self {
        case .name: return TeleportTheme.Colors.textSecondary
        case .rating: return TeleportTheme.Colors.accent
        case .safety: return TeleportTheme.Colors.scoreSafety
        case .cost: return TeleportTheme.Colors.scoreCost
        case .warmClimate: return Color(hex: "FF9500")
        case .coolClimate: return Color(hex: "64D2FF")
        }
    }

    /// The database score category used for server-side sorting.
    var scoreCategory: String? {
        switch self {
        case .name: return nil
        case .rating: return nil  // uses teleport_city_score on City
        case .safety: return "Safety"
        case .cost: return "Cost of Living"
        case .warmClimate: return "Environmental Quality"
        case .coolClimate: return "Environmental Quality"
        }
    }

    var subtitle: String {
        switch self {
        case .name: return "Alphabetical"
        case .rating: return "Overall score"
        case .safety: return "Lowest crime"
        case .cost: return "Most affordable"
        case .warmClimate: return "Warmest climate"
        case .coolClimate: return "Coolest climate"
        }
    }
}

// MARK: - Search View (iOS 26 Search Tab)

struct SearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var searchResults: [City] = []
    @State private var isSearching = false
    @State private var activeSort: CitySortOption = .name
    @State private var sortedCities: [(City, Double)] = []
    @State private var isSortLoading = false

    private var searchText: String {
        coordinator.searchText
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TeleportTheme.Spacing.xl) {
                // Heading card (when user has a saved heading)
                headingCard

                if !searchText.isEmpty {
                    searchResultsSection
                } else {
                    // Sort pill row
                    sortBar

                    if activeSort == .name {
                        trendingSection
                        allCitiesSection
                    } else {
                        sortedCitiesSection
                    }
                }
            }
            .padding(.top, TeleportTheme.Spacing.md)
            .padding(.bottom, TeleportTheme.Spacing.xxl)
        }
        .background(TeleportTheme.Colors.background)
        .navigationDestination(for: City.self) { city in
            CityDetailView(city: city)
        }
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("search")
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("search", durationMs: ms, exitType: "tab_switch")
        }
        .onChange(of: searchText) { _, newValue in
            Task { await performSearch(query: newValue) }
        }
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TeleportTheme.Spacing.sm) {
                ForEach(CitySortOption.allCases) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeSort = option
                        }
                        Task { await loadSortedCities() }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: option.icon)
                                .font(.system(size: 11))
                            Text(option.rawValue)
                                .font(TeleportTheme.Typography.caption(13))
                        }
                        .foregroundStyle(
                            activeSort == option
                                ? TeleportTheme.Colors.background
                                : TeleportTheme.Colors.textSecondary
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            activeSort == option
                                ? option.color
                                : TeleportTheme.Colors.surface
                        )
                        .clipShape(Capsule())
                        .overlay {
                            if activeSort != option {
                                Capsule().strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - Sorted Cities Section

    private var sortedCitiesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            HStack {
                SectionHeader(title: "Top by \(activeSort.rawValue)", color: activeSort.color)
                Spacer()
                if isSortLoading {
                    ProgressView()
                        .tint(activeSort.color)
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)

            if sortedCities.isEmpty && !isSortLoading {
                VStack(spacing: TeleportTheme.Spacing.md) {
                    ProgressView()
                        .tint(TeleportTheme.Colors.accent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, TeleportTheme.Spacing.xl)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sortedCities.enumerated()), id: \.element.0.id) { index, item in
                        let (city, score) = item
                        NavigationLink(value: city) {
                            sortedCityRow(city, score: score, rank: index + 1)
                                .padding(.horizontal, TeleportTheme.Spacing.lg)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func sortedCityRow(_ city: City, score: Double, rank: Int) -> some View {
        HStack(spacing: TeleportTheme.Spacing.md) {
            // Rank number
            Text("\(rank)")
                .font(TeleportTheme.Typography.caption(14))
                .foregroundStyle(rank <= 3 ? activeSort.color : TeleportTheme.Colors.textTertiary)
                .fontWeight(rank <= 3 ? .bold : .regular)
                .frame(width: 24, alignment: .center)

            AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(TeleportTheme.Colors.surfaceElevated)
                        .overlay {
                            Image(systemName: "building.2")
                                .font(.system(size: 14))
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(TeleportTheme.Typography.cardTitle(15))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                Text(city.country)
                    .font(TeleportTheme.Typography.caption(13))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }

            Spacer()

            // Score pill
            HStack(spacing: 4) {
                Image(systemName: activeSort.icon)
                    .font(.system(size: 10))
                Text(String(format: "%.1f", score))
                    .font(TeleportTheme.Typography.cardTitle(14))
            }
            .foregroundStyle(activeSort.color)

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
        }
        .padding(.vertical, TeleportTheme.Spacing.md)
        .contentShape(Rectangle())
    }

    // MARK: - Heading Card

    @ViewBuilder
    private var headingCard: some View {
        if let weights = coordinator.preferences.signalWeights, !weights.isEmpty {
            let heading = HeadingEngine.heading(fromRaw: weights)

            CardView {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    Text(heading.emoji)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        Text(heading.name)
                            .font(TeleportTheme.Typography.cardTitle(17))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        if !heading.topSignals.isEmpty {
                            HStack(spacing: TeleportTheme.Spacing.xs) {
                                ForEach(heading.topSignals) { signal in
                                    HStack(spacing: 3) {
                                        Text(signal.emoji)
                                            .font(.system(size: 10))
                                        Text(signal.shortLabel)
                                            .font(TeleportTheme.Typography.caption(11))
                                            .foregroundStyle(signal.color)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    Text("Plan a Trip")
                        .font(TeleportTheme.Typography.caption(13))
                        .foregroundStyle(TeleportTheme.Colors.accent)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .onTapGesture {
                analytics.trackButtonTap("heading_plan_trip", screen: "search")
                coordinator.showNewExplorationModal = true
            }
        } else {
            // No heading — show exploration prompt
            CardView {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    Image(systemName: "safari")
                        .font(.system(size: 28))
                        .foregroundStyle(TeleportTheme.Colors.accent)

                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        Text("Discover Your Heading")
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        Text("Start an exploration to find your travel personality")
                            .font(TeleportTheme.Typography.caption(13))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .onTapGesture {
                analytics.trackButtonTap("new_exploration", screen: "search")
                coordinator.showNewExplorationModal = true
            }
        }
    }

    // MARK: - New Exploration CTA

    private var newExplorationCTA: some View {
        CardView {
            HStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(TeleportTheme.Colors.accent)

                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text("New Exploration")
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    Text("Discover cities that match your lifestyle")
                        .font(TeleportTheme.Typography.caption(13))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
        .onTapGesture {
            analytics.trackButtonTap("new_exploration", screen: "search")
            coordinator.showNewExplorationModal = true
        }
    }

    // MARK: - Search Results

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            if isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(TeleportTheme.Colors.accent)
                    Spacer()
                }
                .padding(.top, TeleportTheme.Spacing.xl)
            } else if searchResults.isEmpty {
                VStack(spacing: TeleportTheme.Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    Text("No cities found for \"\(searchText)\"")
                        .font(TeleportTheme.Typography.body())
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, TeleportTheme.Spacing.xl)
            } else {
                SectionHeader(title: "Results")
                    .padding(.horizontal, TeleportTheme.Spacing.lg)

                VStack(spacing: 0) {
                    ForEach(searchResults) { city in
                        NavigationLink(value: city) {
                            cityRow(city)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
        }
    }

    // MARK: - Trending Section

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            SectionHeader(title: "Trending")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    ForEach(coordinator.cityService.trendingCities) { city in
                        NavigationLink(value: city) {
                            TrendingChip(title: city.name) {}
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
        }
    }

    // MARK: - All Cities Section

    private var allCitiesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            SectionHeader(title: "All Cities")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            LazyVStack(spacing: 0) {
                ForEach(coordinator.cityService.allCities) { city in
                    NavigationLink(value: city) {
                        cityRow(city)
                            .padding(.horizontal, TeleportTheme.Spacing.lg)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - City Row

    private func cityRow(_ city: City) -> some View {
        HStack(spacing: TeleportTheme.Spacing.md) {
            AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(TeleportTheme.Colors.surfaceElevated)
                        .overlay {
                            Image(systemName: "building.2")
                                .font(.system(size: 14))
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(TeleportTheme.Typography.cardTitle(15))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                Text(city.country)
                    .font(TeleportTheme.Typography.caption(13))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }

            Spacer()

            if let score = city.teleportCityScore {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                    Text(String(format: "%.0f", score))
                        .font(TeleportTheme.Typography.caption(12))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
        }
        .padding(.vertical, TeleportTheme.Spacing.md)
        .contentShape(Rectangle())
    }

    // MARK: - Data Loading

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        searchResults = await coordinator.cityService.searchCities(query: query)
        isSearching = false
        analytics.track("search_performed", screen: "search", properties: [
            "query_length": String(query.count),
            "result_count": String(searchResults.count)
        ])
    }

    private func loadSortedCities() async {
        guard activeSort != .name else {
            sortedCities = []
            return
        }

        isSortLoading = true
        defer { isSortLoading = false }

        if activeSort == .rating {
            // Sort locally by teleport_city_score
            let sorted = coordinator.cityService.allCities
                .sorted { ($0.teleportCityScore ?? 0) > ($1.teleportCityScore ?? 0) }
                .prefix(50)
            sortedCities = sorted.map { ($0, $0.teleportCityScore ?? 0) }
        } else if let category = activeSort.scoreCategory {
            let results = await coordinator.cityService.citiesSortedByCategory(category, limit: 50)
            if activeSort == .coolClimate {
                // Reverse: lowest Environmental Quality = coolest
                sortedCities = results.reversed()
            } else {
                sortedCities = results
            }
        }

        analytics.track("sort_applied", screen: "search", properties: [
            "sort_option": activeSort.rawValue
        ])
    }
}

// MARK: - Preview

#Preview("Search") {
    PreviewContainer {
        NavigationStack {
            SearchView()
                .navigationTitle("Search")
        }
    }
}
