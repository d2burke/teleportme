import SwiftUI

// MARK: - Discover Tab

struct DiscoverView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    private var explorations: [Exploration] {
        coordinator.explorationService.explorations
    }

    private var matches: [CityMatch] {
        coordinator.reportService.currentReport?.matches ?? []
    }

    private var trendingCities: [City] {
        coordinator.cityService.trendingCities
    }

    private var allCities: [City] {
        coordinator.cityService.allCities
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xl) {
                    // MARK: Header
                    headerSection

                    // Error banner (shown when city fetch fails)
                    if let error = coordinator.cityService.loadError {
                        errorBanner(message: error) {
                            Task { await coordinator.cityService.retryFetch() }
                        }
                    }

                    // MARK: Your Explorations
                    explorationsSection

                    // MARK: Latest Results (from most recent exploration/report)
                    if !matches.isEmpty {
                        latestMatchesSection
                    }

                    // MARK: Trending Cities
                    trendingSection
                }
                .padding(.bottom, TeleportTheme.Spacing.xxl)
            }
            .background(TeleportTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: City.self) { city in
                CityDetailView(city: city)
            }
            .navigationDestination(for: Exploration.self) { exploration in
                ExplorationDetailView(exploration: exploration)
            }
            .task {
                await coordinator.cityService.fetchAllCities()
            }
        }
        .tint(TeleportTheme.Colors.textPrimary)
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("discover")
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("discover", durationMs: ms, exitType: "tab_switch")
        }
    }

    // MARK: - Error Banner

    private func errorBanner(message: String, onRetry: @escaping () -> Void) -> some View {
        CardView {
            VStack(spacing: TeleportTheme.Spacing.sm) {
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 20))
                        .foregroundStyle(.red.opacity(0.8))

                    Text("Unable to load cities")
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                }

                Text(message)
                    .font(TeleportTheme.Typography.caption())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                Button(action: onRetry) {
                    Text("Retry")
                        .font(TeleportTheme.Typography.cardTitle(14))
                        .foregroundStyle(TeleportTheme.Colors.background)
                        .padding(.horizontal, TeleportTheme.Spacing.lg)
                        .padding(.vertical, TeleportTheme.Spacing.sm)
                        .background(TeleportTheme.Colors.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
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

    // MARK: - Your Explorations

    private var explorationsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            HStack {
                SectionHeader(title: "Your Explorations")

                Spacer()

                // "+" button to start a new exploration
                Button {
                    analytics.trackButtonTap("new_exploration", screen: "discover", properties: ["source": "plus_button"])
                    coordinator.showNewExplorationModal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)

            if explorations.isEmpty {
                explorationsEmptyState
            } else {
                explorationsCarousel
            }
        }
    }

    private var explorationsEmptyState: some View {
        CardView {
            VStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(TeleportTheme.Colors.accent)

                Text("No explorations yet")
                    .font(TeleportTheme.Typography.cardTitle())
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)

                Text("Create your first exploration to discover cities that match your vibe")
                    .font(TeleportTheme.Typography.body(14))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                TeleportButton(
                    title: "New Exploration",
                    icon: "plus.circle.fill",
                    isLoading: false
                ) {
                    analytics.trackButtonTap("new_exploration", screen: "discover", properties: ["source": "empty_state"])
                    coordinator.showNewExplorationModal = true
                }
                .padding(.horizontal, TeleportTheme.Spacing.md)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TeleportTheme.Spacing.xl)
        }
        .padding(.horizontal, TeleportTheme.Spacing.lg)
    }

    private var explorationsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(explorations) { exploration in
                    NavigationLink(value: exploration) {
                        explorationCard(exploration)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
        }
    }

    private func explorationCard(_ exploration: Exploration) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            // Top badge row
            HStack {
                // Start type icon
                Image(systemName: startTypeIcon(exploration.startType))
                    .font(.system(size: 14))
                    .foregroundStyle(TeleportTheme.Colors.accent)

                Spacer()

                // Result count
                Text("\(exploration.results.count) cities")
                    .font(TeleportTheme.Typography.caption(11))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }

            // Title
            Text(exploration.title)
                .font(TeleportTheme.Typography.cardTitle(16))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                .lineLimit(2)

            // Baseline city
            if let cityId = exploration.baselineCityId,
               let city = allCities.first(where: { $0.id == cityId }) {
                Text("Based on \(city.name)")
                    .font(TeleportTheme.Typography.caption(12))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Date
            if let date = exploration.createdAt {
                Text(date, style: .date)
                    .font(TeleportTheme.Typography.caption(11))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }
        }
        .padding(TeleportTheme.Spacing.md)
        .frame(width: 180, height: 160)
        .background(TeleportTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: TeleportTheme.Radius.card)
                .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
        }
    }

    private func startTypeIcon(_ startType: StartType) -> String {
        switch startType {
        case .cityILove: return "heart.fill"
        case .vibes: return "waveform"
        case .myWords: return "text.quote"
        }
    }

    // MARK: - Latest Matches (from current report)

    private var latestMatchesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Latest Results")
                .padding(.horizontal, TeleportTheme.Spacing.lg)

            matchesCarousel
        }
    }

    /// Resolves a CityMatch to its full City model.
    private func city(for match: CityMatch) -> City? {
        allCities.first { $0.id == match.cityId }
    }

    private var matchesCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(matches) { match in
                    if let city = city(for: match) {
                        NavigationLink(value: city) {
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
                        .buttonStyle(.plain)
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
                            NavigationLink(value: city) {
                                trendingCityCard(city: city)
                            }
                            .buttonStyle(.plain)
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
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isSaved)
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
