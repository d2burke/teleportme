import SwiftUI

struct RootView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        Group {
            switch coordinator.currentScreen {
            case .loading:
                LoadingView()
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingFlowView()
            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screenKey)
        .task {
            await coordinator.checkExistingSession()
        }
    }

    private var screenKey: String {
        switch coordinator.currentScreen {
        case .loading: "loading"
        case .splash: "splash"
        case .onboarding: "onboarding"
        case .main: "main"
        }
    }
}

// MARK: - Loading View (matches launch screen)

/// Displayed while checking auth state. Visually identical to the system launch screen
/// so the transition from launch → loading is seamless. Once the session check completes
/// this transitions to either SplashView (unauthenticated) or MainTabView (authenticated).
struct LoadingView: View {
    private let analytics = AnalyticsService.shared
    @State private var screenEnteredAt = Date()

    var body: some View {
        ZStack {
            TeleportTheme.Colors.background
                .ignoresSafeArea()

            Image("LaunchLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
        }
        .onAppear { analytics.trackScreenView("loading") }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("loading", durationMs: ms, exitType: "completed")
        }
    }
}

// MARK: - Onboarding Flow Container

struct OnboardingFlowView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coord = coordinator

        NavigationStack(path: $coord.navigationPath) {
            NameInputView()
                .navigationDestination(for: OnboardingStep.self) { step in
                    destinationView(for: step)
                }
        }
        .tint(TeleportTheme.Colors.textPrimary)
    }

    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        @Bindable var coord = coordinator

        switch step {
        case .name:
            NameInputView()
        case .signUp:
            SignUpView()
        case .startType:
            ExplorationMethodStepView(
                startType: $coord.selectedStartType,
                onContinue: {
                    coordinator.advanceOnboarding(from: .startType)
                }
            )
        case .citySearch:
            CitySearchView()
        case .cityBaseline:
            CityBaselineView()
        case .tripVibes:
            TripVibesView(
                signalWeights: $coord.signalWeights,
                onContinue: {
                    coordinator.advanceOnboarding(from: .tripVibes)
                },
                onBack: {
                    coordinator.goBackOnboarding(from: .tripVibes)
                }
            )
        case .constraints:
            ConstraintsView(
                constraints: $coord.tripConstraints,
                onContinue: {
                    coordinator.advanceOnboarding(from: .constraints)
                },
                onBack: {
                    coordinator.goBackOnboarding(from: .constraints)
                }
            )
        case .generating:
            onboardingGeneratingView
        case .recommendations:
            RecommendationsView()
        }
    }

    /// Bridges the onboarding coordinator state into `ExplorationGeneratingStepView`,
    /// the single generating view used by both onboarding and new-exploration flows.
    @ViewBuilder
    private var onboardingGeneratingView: some View {
        let compassVibes: [String: Double]? = coordinator.signalWeights.isEmpty
            ? nil
            : Dictionary(uniqueKeysWithValues: coordinator.signalWeights.map { ($0.key.rawValue, $0.value) })
        let constraints: TripConstraints? = coordinator.tripConstraints.hasAny
            ? coordinator.tripConstraints
            : nil
        let heading = HeadingEngine.heading(from: coordinator.signalWeights)
        let title: String = if !heading.topSignals.isEmpty {
            "\(heading.emoji) \(heading.name) Trip"
        } else if let cityName = coordinator.selectedCity?.city.name {
            "\(cityName) Exploration"
        } else {
            "My First Exploration"
        }

        ExplorationGeneratingStepView(
            title: title,
            startType: coordinator.selectedStartType,
            baselineCityId: coordinator.selectedCityId,
            preferences: coordinator.preferences,
            vibeTags: coordinator.selectedVibeIds.isEmpty ? nil : Array(coordinator.selectedVibeIds),
            userVibeTags: coordinator.preferences.selectedVibeTags,
            compassVibes: compassVibes,
            compassConstraints: constraints,
            onComplete: { response in
                // Sync evolved heading weights
                if let evolved = response.evolvedWeights {
                    coordinator.preferences.signalWeights = evolved
                    Task { await coordinator.savePreferences() }
                }
                // Update reportService for backward compat with RecommendationsView
                coordinator.reportService.currentReport = response
                if let userId = coordinator.currentUserId {
                    CacheManager.shared.save(response, for: .currentReport(userId: userId))
                }
                coordinator.advanceOnboarding(from: .generating)
            },
            onError: { _ in
                // ExplorationGeneratingStepView has its own retry button
            }
        )
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coord = coordinator

        TabView(selection: $coord.selectedTab) {
            Tab("Discover", systemImage: "safari", value: .discover) {
                DiscoverView()
            }
            Tab("Profile", systemImage: "person", value: .profile) {
                ProfileView()
            }

            // iOS 26 search tab — visually separated on the right (liquid glass)
            // Tapping the search icon morphs into an inline search field above the keyboard
            Tab("Search", systemImage: "magnifyingglass", value: .search, role: .search) {
                NavigationStack {
                    SearchView()
                        .navigationTitle("Search")
                        .searchable(text: $coord.searchText, prompt: "Search cities...")
                }
            }
        }
        .tint(TeleportTheme.Colors.accent)
        .sheet(isPresented: $coord.showNewExplorationModal) {
            NewExplorationFlow()
        }
        .task {
            await coordinator.cityService.fetchAllCities()
        }
    }
}

// MARK: - Previews

#Preview("Splash") {
    PreviewContainer {
        RootView()
    }
}

#Preview("Main Tabs") {
    PreviewContainer {
        MainTabView()
    }
}
