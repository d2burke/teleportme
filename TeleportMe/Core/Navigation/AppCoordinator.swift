import SwiftUI

// MARK: - App State

enum AppScreen {
    case splash
    case onboarding
    case main
}

enum OnboardingStep: Int, CaseIterable, Hashable {
    case name = 0
    case signUp = 1
    case startType = 2
    case citySearch = 3
    case cityBaseline = 4
    case preferences = 5
    case generating = 6
    case recommendations = 7

    var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var previous: OnboardingStep? {
        OnboardingStep(rawValue: rawValue - 1)
    }
}

// MARK: - App Coordinator

@Observable
final class AppCoordinator {
    var currentScreen: AppScreen = .splash
    var navigationPath = NavigationPath()

    // When true, skips Supabase auth calls so you can test the full
    // onboarding flow without creating accounts or hitting rate limits.
    var previewMode: Bool = false

    // Shared services
    let authService = AuthService()
    let cityService = CityService()
    let reportService = ReportService()

    // Onboarding state (collected across screens)
    var onboardingName: String = ""
    var selectedStartType: StartType = .cityILove
    var selectedCityId: String? = nil
    var selectedCity: CityWithScores? = nil
    var preferences: UserPreferences = .defaults

    // MARK: - Navigation

    func startOnboarding() {
        navigationPath = NavigationPath()
        currentScreen = .onboarding
    }

    func advanceOnboarding(from step: OnboardingStep) {
        guard let next = step.next else { return }

        if step == .generating {
            // Replace generating with recommendations so user can't
            // swipe back to the loading screen
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
            navigationPath.append(OnboardingStep.recommendations)
        } else {
            navigationPath.append(next)
        }
    }

    func goBackOnboarding(from step: OnboardingStep) {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func completeOnboarding() {
        navigationPath = NavigationPath()
        currentScreen = .main
    }

    func goToMain() {
        currentScreen = .main
    }

    // MARK: - City Selection (during onboarding)

    func selectCity(_ cityId: String) async {
        selectedCityId = cityId
        selectedCity = await cityService.getCityWithScores(cityId: cityId)

        // Update profile with current city (skip in preview mode)
        if !previewMode {
            try? await authService.updateProfile(currentCityId: cityId)
        }
    }

    // MARK: - Generate Report

    func generateReport() async throws -> GenerateReportResponse {
        guard let cityId = selectedCityId else {
            throw NSError(domain: "TeleportMe", code: 1, userInfo: [NSLocalizedDescriptionKey: "No city selected"])
        }

        return try await reportService.generateReport(
            currentCityId: cityId,
            preferences: preferences
        )
    }

    // MARK: - Session Check

    func checkExistingSession() async {
        if previewMode { return }
        await authService.checkSession()
        if authService.isAuthenticated {
            // Load cities in background
            await cityService.fetchAllCities()
            goToMain()
        }
    }
}
