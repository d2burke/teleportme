import SwiftUI

// MARK: - Discover Tab

struct DiscoverView: View {
    @Environment(AppCoordinator.self) private var coordinator

    private var matches: [CityMatch] {
        coordinator.reportService.currentReport?.matches ?? []
    }

    private var trendingCities: [City] {
        coordinator.cityService.trendingCities
    }

    private var allCities: [City] {
        coordinator.cityService.allCities
    }

    @State private var showAllCities = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xl) {
                // MARK: Header
                headerSection

                // MARK: Your Matches
                matchesSection

                // MARK: Trending Cities
                trendingSection

                // MARK: All Cities
                allCitiesSection
            }
            .padding(.bottom, TeleportTheme.Spacing.xxl)
        }
        .background(TeleportTheme.Colors.background)
        .task {
            await coordinator.cityService.fetchAllCities()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
            Text("Discover")
                .font(TeleportTheme.Typography.heroTitle(36))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)

            Text("Explore cities that match your lifestyle")
                .font(TeleportTheme.Typography.body())
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
        .padding(.top, TeleportTheme.Spacing.md)
    }

    // MARK: - Your Matches

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Your Matches")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            if matches.isEmpty {
                matchesEmptyState
            } else {
                matchesCarousel
            }
        }
    }

    private var matchesEmptyState: some View {
        CardView {
            VStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(TeleportTheme.Colors.accent)

                Text("Run the analysis to see matches")
                    .font(TeleportTheme.Typography.body())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TeleportTheme.Spacing.xl)
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
    }

    private var matchesCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(matches) { match in
                    ZStack(alignment: .topTrailing) {
                        CityHeroImage(
                            imageURL: match.cityImageUrl,
                            cityName: match.cityName,
                            subtitle: match.cityCountry,
                            height: 240,
                            matchPercent: match.matchPercent,
                            rank: match.rank
                        )
                        .frame(width: UIScreen.main.bounds.width - 80, height: 240)

                        saveButton(cityId: match.cityId)
                            .padding(.top, 72)
                            .padding(.trailing, TeleportTheme.Spacing.sm)
                    }
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    // MARK: - Trending Cities

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Trending Cities")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            if trendingCities.isEmpty {
                ProgressView()
                    .tint(TeleportTheme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TeleportTheme.Spacing.lg)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TeleportTheme.Spacing.md) {
                        ForEach(trendingCities) { city in
                            trendingCityCard(city: city)
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
            }
        }
    }

    private func trendingCityCard(city: City) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // City image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
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
                .frame(width: 160, height: 120)
                .clipped()

                saveButton(cityId: city.id)
                    .padding(TeleportTheme.Spacing.xs)
            }

            // City info
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                Text(city.name)
                    .font(TeleportTheme.Typography.cardTitle(15))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(city.country)
                    .font(TeleportTheme.Typography.caption())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .padding(TeleportTheme.Spacing.sm)
        }
        .frame(width: 160, height: 200)
        .background(TeleportTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.card))
    }

    // MARK: - All Cities

    private var allCitiesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "All Cities")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            if allCities.isEmpty {
                ProgressView()
                    .tint(TeleportTheme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TeleportTheme.Spacing.lg)
            } else {
                let displayedCities = showAllCities ? allCities : Array(allCities.prefix(20))

                LazyVStack(spacing: TeleportTheme.Spacing.sm) {
                    ForEach(displayedCities) { city in
                        cityRow(city: city)
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)

                if !showAllCities && allCities.count > 20 {
                    TeleportButton(title: "See All", style: .ghost) {
                        showAllCities = true
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
            }
        }
    }

    private func cityRow(city: City) -> some View {
        HStack(spacing: TeleportTheme.Spacing.md) {
            // Thumbnail
            AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle().fill(TeleportTheme.Colors.surfaceElevated)
                default:
                    Rectangle().fill(TeleportTheme.Colors.surfaceElevated)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

            // Name + Country
            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(TeleportTheme.Typography.cardTitle(15))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(city.country)
                    .font(TeleportTheme.Typography.caption())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Score badge
            if let score = city.teleportCityScore {
                Text(String(format: "%.0f", score))
                    .font(TeleportTheme.Typography.caption(13))
                    .foregroundStyle(TeleportTheme.Colors.background)
                    .padding(.horizontal, TeleportTheme.Spacing.sm)
                    .padding(.vertical, TeleportTheme.Spacing.xs)
                    .background(TeleportTheme.Colors.accent)
                    .clipShape(Capsule())
            }

            // Heart button
            saveButton(cityId: city.id)
        }
        .padding(TeleportTheme.Spacing.sm)
        .background(TeleportTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
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
}

// MARK: - Preview

#Preview("Discover") {
    PreviewContainer(coordinator: PreviewHelpers.makeCoordinatorWithReport()) {
        DiscoverView()
    }
}

#Preview("Discover - Empty") {
    PreviewContainer {
        DiscoverView()
    }
}
