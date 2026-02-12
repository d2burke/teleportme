import SwiftUI

@main
struct TeleportMeApp: App {
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
            case "preferences":
                coord = PreviewHelpers.makeCoordinator()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
                coord.navigationPath.append(OnboardingStep.preferences)
            case "recommendations":
                coord = PreviewHelpers.makeCoordinatorWithReport()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
                coord.navigationPath.append(OnboardingStep.preferences)
                coord.navigationPath.append(OnboardingStep.recommendations)
            case "generating":
                coord = PreviewHelpers.makeCoordinator()
                coord.currentScreen = .onboarding
                coord.navigationPath.append(OnboardingStep.signUp)
                coord.navigationPath.append(OnboardingStep.startType)
                coord.navigationPath.append(OnboardingStep.citySearch)
                coord.navigationPath.append(OnboardingStep.cityBaseline)
                coord.navigationPath.append(OnboardingStep.preferences)
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
        }
    }
}
