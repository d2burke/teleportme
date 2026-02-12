import SwiftUI
import Supabase

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
    let savedCitiesService = SavedCitiesService()

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

        // Persist preferences to Supabase when leaving the preferences step
        if step == .preferences {
            Task { await savePreferences() }
        }

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

    // MARK: - Save Preferences

    func savePreferences() async {
        // Skip in preview mode or if user is not authenticated
        guard !previewMode, let userId = authService.currentUser?.id else { return }

        let data = UserPreferencesRow(
            userId: userId.uuidString,
            startType: preferences.startType.rawValue,
            costPreference: preferences.costPreference,
            climatePreference: preferences.climatePreference,
            culturePreference: preferences.culturePreference,
            jobMarketPreference: preferences.jobMarketPreference
        )

        do {
            try await SupabaseManager.shared.client
                .from("user_preferences")
                .upsert(data)
                .execute()
        } catch {
            print("Failed to save preferences: \(error)")
        }
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

// MARK: - User Preferences Row (for Supabase upsert)

private struct UserPreferencesRow: Encodable {
    let userId: String
    let startType: String
    let costPreference: Double
    let climatePreference: Double
    let culturePreference: Double
    let jobMarketPreference: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case startType = "start_type"
        case costPreference = "cost_preference"
        case climatePreference = "climate_preference"
        case culturePreference = "culture_preference"
        case jobMarketPreference = "job_market_preference"
    }
}
