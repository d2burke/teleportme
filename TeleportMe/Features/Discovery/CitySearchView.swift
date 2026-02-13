import SwiftUI

struct CitySearchView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var searchText = ""
    @State private var searchResults: [City] = []
    @State private var isSearching = false
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: TeleportTheme.Spacing.xl) {
                // Hero image area (simplified card stack)
                ZStack {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.large)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 220, height: 260)
                        .rotationEffect(.degrees(5))

                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=400&q=80")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Rectangle().fill(TeleportTheme.Colors.surface)
                        }
                    }
                    .frame(width: 240, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.large))
                    .overlay(alignment: .center) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, TeleportTheme.Spacing.md)

                // Title
                VStack(spacing: TeleportTheme.Spacing.sm) {
                    Text("Where do you\nlive now?")
                        .font(TeleportTheme.Typography.title(30))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Start with a city you love and why. We'll show you similar ones.")
                        .font(TeleportTheme.Typography.body(15))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TeleportTheme.Spacing.xl)
                }

                // Search bar
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    TextField("Search for your city", text: $searchText)
                        .font(TeleportTheme.Typography.body())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        .autocorrectionDisabled()
                        .tint(TeleportTheme.Colors.accent)
                }
                .padding(TeleportTheme.Spacing.md)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .onChange(of: searchText) { _, newValue in
                    Task { await performSearch(query: newValue) }
                }

                // Search results or trending
                if !searchResults.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(searchResults.enumerated()), id: \.1.id) { index, city in
                            CitySearchRow(city: city) {
                                analytics.trackButtonTap("search_result", screen: "city_search", properties: [
                                    "city_id": city.id, "rank": String(index + 1)
                                ])
                                analytics.track("city_selected", screen: "city_search", properties: [
                                    "city_id": city.id, "city_name": city.name, "source": "search"
                                ])
                                Task {
                                    await coordinator.selectCity(city.id)
                                    coordinator.advanceOnboarding(from: .citySearch)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                } else if searchText.isEmpty {
                    // Trending cities
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                        Text("TRENDING NOW")
                            .font(TeleportTheme.Typography.sectionHeader())
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                            .tracking(1.5)
                            .padding(.horizontal, TeleportTheme.Spacing.lg)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: TeleportTheme.Spacing.sm) {
                                ForEach(coordinator.cityService.trendingCities) { city in
                                    TrendingChip(title: city.name) {
                                        analytics.trackButtonTap("trending_city", screen: "city_search", properties: ["city_id": city.id])
                                        analytics.track("city_selected", screen: "city_search", properties: [
                                            "city_id": city.id, "city_name": city.name, "source": "trending"
                                        ])
                                        Task {
                                            await coordinator.selectCity(city.id)
                                            coordinator.advanceOnboarding(from: .citySearch)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, TeleportTheme.Spacing.lg)
                        }
                    }
                }

                // "Let's roll" button when a search term is entered but no selection yet
                if !searchText.isEmpty && searchResults.isEmpty && !isSearching {
                    Text("No cities found for \"\(searchText)\"")
                        .font(TeleportTheme.Typography.body())
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }
            .padding(.bottom, TeleportTheme.Spacing.xxl)
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("city_search")
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("city_search", durationMs: ms, exitType: "advanced")
        }
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        searchResults = await coordinator.cityService.searchCities(query: query)
        isSearching = false
        analytics.track("search_performed", screen: "city_search", properties: [
            "query_length": String(query.count),
            "result_count": String(searchResults.count)
        ])
    }
}

// MARK: - City Search Row

struct CitySearchRow: View {
    let city: City
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(TeleportTheme.Colors.surface)
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
                    .font(.caption)
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }
            .padding(.vertical, TeleportTheme.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("City Search") {
    PreviewContainer {
        CitySearchView()
    }
}

#Preview("City Search Row") {
    CitySearchRow(city: PreviewHelpers.sampleCity) {}
        .padding()
        .background(TeleportTheme.Colors.background)
        .preferredColorScheme(.dark)
}
