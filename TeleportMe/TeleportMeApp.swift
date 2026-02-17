import SwiftUI

@main
struct TeleportMeApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var appCoordinator: AppCoordinator

    init() {
        // Configure navigation bar appearance for dark theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(TeleportTheme.Colors.background)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        // Hide "Back" text, keep chevron only
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
        appearance.backButtonAppearance = backButtonAppearance

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white

        let coord: AppCoordinator
        #if DEBUG
        // Launch with DEBUG_SCREEN env var to jump to a specific screen
        // e.g. SIMCTL_CHILD_DEBUG_SCREEN=preferences xcrun simctl launch ...
        if let debugScreen = ProcessInfo.processInfo.environment["DEBUG_SCREEN"] {
            switch debugScreen {
            case "cityBaseline":
                coord = PreviewHelpers.makeCoordinator()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
            case "tripVibes":
                coord = PreviewHelpers.makeCoordinator()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
                coord.navigationPath.append(OnboardingStep.tripVibes)
            case "constraints":
                coord = PreviewHelpers.makeCoordinator()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
                coord.navigationPath.append(OnboardingStep.tripVibes)
                coord.navigationPath.append(OnboardingStep.constraints)
            case "recommendations":
                coord = PreviewHelpers.makeCoordinatorWithReport()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
                coord.navigationPath.append(OnboardingStep.tripVibes)
                coord.navigationPath.append(OnboardingStep.constraints)
                coord.navigationPath.append(OnboardingStep.recommendations)
            case "generating":
                coord = PreviewHelpers.makeCoordinator()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
                coord.navigationPath.append(OnboardingStep.tripVibes)
                coord.navigationPath.append(OnboardingStep.constraints)
                coord.navigationPath.append(OnboardingStep.generating)
            case "main":
                coord = PreviewHelpers.makeCoordinatorWithReport()
                coord.currentScreen = .main
            default:
                coord = AppCoordinator()
            }
        } else {
            coord = AppCoordinator()
        }
        #else
        coord = AppCoordinator()
        #endif
        _appCoordinator = State(initialValue: coord)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appCoordinator)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    appCoordinator.handleDeepLink(url)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // Drain any events persisted from a previous session
                appCoordinator.analytics.drainPersistedEvents()
            case .background:
                // Flush + persist before going to background
                appCoordinator.analytics.handleBackgroundTransition()
            default:
                break
            }
        }
    }
}
