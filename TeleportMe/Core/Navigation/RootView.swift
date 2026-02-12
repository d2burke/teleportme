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
        TabView {
            Tab("Discover", systemImage: "safari") {
                DiscoverPlaceholderView()
            }
            Tab("Saved", systemImage: "heart") {
                SavedPlaceholderView()
            }
            Tab("Map", systemImage: "map") {
                MapPlaceholderView()
            }
            Tab("Profile", systemImage: "person") {
                ProfilePlaceholderView()
            }
        }
        .tint(TeleportTheme.Colors.accent)
        .task {
            await coordinator.cityService.fetchAllCities()
        }
    }
}

// MARK: - Placeholder Tabs

struct DiscoverPlaceholderView: View {
    var body: some View {
        ZStack {
            TeleportTheme.Colors.background.ignoresSafeArea()
            VStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: "safari")
                    .font(.system(size: 48))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                Text("Discover")
                    .font(TeleportTheme.Typography.title())
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                Text("Your city discovery feed will live here")
                    .font(TeleportTheme.Typography.body())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }
        }
    }
}

struct SavedPlaceholderView: View {
    var body: some View {
        ZStack {
            TeleportTheme.Colors.background.ignoresSafeArea()
            VStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: "heart")
                    .font(.system(size: 48))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                Text("Saved Cities")
                    .font(TeleportTheme.Typography.title())
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
            }
        }
    }
}

struct MapPlaceholderView: View {
    var body: some View {
        ZStack {
            TeleportTheme.Colors.background.ignoresSafeArea()
            VStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: "map")
                    .font(.system(size: 48))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                Text("Map")
                    .font(TeleportTheme.Typography.title())
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
            }
        }
    }
}

struct ProfilePlaceholderView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ZStack {
            TeleportTheme.Colors.background.ignoresSafeArea()
            VStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: "person")
                    .font(.system(size: 48))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                Text("Profile")
                    .font(TeleportTheme.Typography.title())
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)

                if let name = coordinator.authService.currentProfile?.name {
                    Text(name)
                        .font(TeleportTheme.Typography.body())
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }

                TeleportButton(title: "Sign Out", style: .secondary) {
                    Task { await coordinator.authService.signOut() }
                    coordinator.currentScreen = .splash
                }
                .padding(.horizontal, TeleportTheme.Spacing.xl)
            }
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
