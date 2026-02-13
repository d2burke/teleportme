import SwiftUI

struct RootView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        Group {
            switch coordinator.currentScreen {
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
        case .splash: "splash"
        case .onboarding: "onboarding"
        case .main: "main"
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
        }
        .tint(TeleportTheme.Colors.accent)
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
