import SwiftUI

// MARK: - Search View (iOS 26 Search Tab)

struct SearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var searchResults: [City] = []
    @State private var isSearching = false

    private var searchText: String {
        coordinator.searchText
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TeleportTheme.Spacing.xl) {
                // New Exploration CTA
                newExplorationCTA

                if !searchText.isEmpty {
                    // Search results
                    searchResultsSection
                } else {
                    // Default content when not searching
                    trendingSection
                    allCitiesSection
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

    // MARK: - City Row (used by search results and all-cities)

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

    // MARK: - Search

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
