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
        switch step {
        case .name:
            NameInputView()
        case .signUp:
            SignUpView()
        case .startType:
            StartTypeView()
        case .citySearch:
            CitySearchView()
        case .cityBaseline:
            CityBaselineView()
        case .preferences:
            PreferencesView()
        case .generating:
            GeneratingView()
        case .recommendations:
            RecommendationsView()
        }
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
            Tab("Saved", systemImage: "heart", value: .saved) {
                SavedView()
            }
            Tab("Map", systemImage: "map", value: .map) {
                CityMapView()
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
