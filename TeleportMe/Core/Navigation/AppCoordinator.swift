import SwiftUI
import Supabase

// MARK: - App State

enum AppScreen {
    case loading     // Launch → checking auth state
    case splash      // Unauthenticated landing / getting started
    case onboarding  // Onboarding flow
    case main        // Main app with tab view
}

/// Tabs in the main TabView, selectable via deep link.
enum AppTab: String, Hashable {
    case discover
    case saved
    case map
    case profile
    case search
}

/// Routes the app can handle via Universal Links or custom URL scheme.
/// Supports: https://getteleport.me/profile  AND  teleportme://profile
enum DeepLink {
    case authCallback(URL)   // /auth/callback – Supabase PKCE exchange
    case tab(AppTab)         // /profile, /discover, /saved, /map

    init?(url: URL) {
        // For custom scheme (teleportme://profile), the route is in `host`.
        // For https (https://getteleport.me/profile), it's in `path`.
        let route: String
        if url.scheme == "teleportme" {
            route = url.host ?? url.path
        } else {
            route = url.path
        }
        let cleaned = route.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        switch cleaned {
        case "auth/callback":
            self = .authCallback(url)
        case "profile":
            self = .tab(.profile)
        case "discover":
            self = .tab(.discover)
        case "saved":
            self = .tab(.saved)
        case "map":
            self = .tab(.map)
        case "search":
            self = .tab(.search)
        default:
            return nil
        }
    }
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
    var currentScreen: AppScreen = .loading
    var navigationPath = NavigationPath()
    var selectedTab: AppTab = .discover

    // When true, skips Supabase auth calls so you can test the full
    // onboarding flow without creating accounts or hitting rate limits.
    var previewMode: Bool = false

    // Shared services
    let authService = AuthService()
    let cityService = CityService()
    let reportService = ReportService()
    let explorationService = ExplorationService()
    let savedCitiesService = SavedCitiesService()
    let analytics = AnalyticsService.shared

    // Search text for the iOS 26 search tab
    var searchText: String = ""

    // Whether the new exploration modal is presented
    var showNewExplorationModal = false

    private let cache = CacheManager.shared

    /// Convenience accessor for the current user's ID string.
    /// Avoids needing to import Auth in view files.
    var currentUserId: String? {
        authService.currentUser?.id.uuidString
    }

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

    // MARK: - Deep Link Routing

    /// Handles an incoming Universal Link URL.
    /// Auth callbacks are forwarded to AuthService; tab links switch the active tab.
    func handleDeepLink(_ url: URL) {
        guard let link = DeepLink(url: url) else {
            print("Unrecognised deep link: \(url)")
            return
        }

        switch link {
        case .authCallback(let callbackURL):
            authService.handleDeepLink(callbackURL)

        case .tab(let tab):
            // If the user is already on main, just switch tabs
            if currentScreen == .main {
                selectedTab = tab
            } else {
                // Queue the tab switch — once session check completes and
                // transitions to main, the selectedTab will already be set.
                selectedTab = tab
                // If we have an authenticated user, jump straight to main
                if authService.isAuthenticated {
                    currentScreen = .main
                }
            }
        }
    }

    // MARK: - City Selection (during onboarding)

    func selectCity(_ cityId: String) async {
        selectedCityId = cityId
        selectedCity = await cityService.getCityWithScores(cityId: cityId)

        // Prefill preferences from the selected city's scores
        // so the sliders start at values that reflect the city the user loves
        if let city = selectedCity {
            preferences = .fromCity(city)
        }

        // Write-through cache
        if let userId = authService.currentUser?.id.uuidString,
           let city = selectedCity {
            cache.save(city, for: .selectedCity(userId: userId))
        }

        // Update profile with current city (skip in preview mode)
        if !previewMode {
            try? await authService.updateProfile(currentCityId: cityId)
        }
    }

    // MARK: - Generate Report (Onboarding)

    /// Generates a report during onboarding. This creates both a legacy report AND a new Exploration.
    /// The exploration title defaults to "[CityName] Exploration" based on the selected city.
    func generateReport() async throws -> GenerateReportResponse {
        let userId = authService.currentUser?.id.uuidString

        // Build a default exploration title
        let cityName = selectedCity?.city.name ?? "My First"
        let defaultTitle = "\(cityName) Exploration"

        // Route through ExplorationService (which calls the same edge function)
        let response = try await explorationService.generateExploration(
            title: defaultTitle,
            startType: selectedStartType,
            baselineCityId: selectedCityId,
            preferences: preferences,
            userId: userId
        )

        // Also set on reportService for backward compat with existing views
        reportService.currentReport = response
        if let userId {
            CacheManager.shared.save(response, for: .currentReport(userId: userId))
        }

        return response
    }

    // MARK: - Save Preferences

    func savePreferences() async {
        // Skip in preview mode or if user is not authenticated
        guard !previewMode, let userId = authService.currentUser?.id else { return }

        let userIdString = userId.uuidString

        // Write-through to cache immediately
        cache.save(preferences, for: .preferences(userId: userIdString))

        let data = UserPreferencesRow(
            userId: userIdString,
            startType: preferences.startType.rawValue,
            costPreference: preferences.costPreference,
            climatePreference: preferences.climatePreference,
            culturePreference: preferences.culturePreference,
            jobMarketPreference: preferences.jobMarketPreference,
            safetyPreference: preferences.safetyPreference,
            commutePreference: preferences.commutePreference,
            healthcarePreference: preferences.healthcarePreference
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
            let userId = authService.currentUser?.id.uuidString

            // Set userId on services so they can operate offline
            if let userId {
                savedCitiesService.cachedUserId = userId
                analytics.userId = userId
                restoreCachedState(userId: userId)
            }

            // Load cities (will use disk cache if available)
            await cityService.fetchAllCities()

            // Load explorations (cache-then-network)
            if let userId {
                await explorationService.loadExplorations(userId: userId)
            }

            // If no currentReport was restored from cache, try loading the latest from network
            if reportService.currentReport == nil, let userId {
                let reports = await reportService.loadReports(userId: userId)
                if let latest = reports.first, let results = latest.results as [CityMatch]? {
                    reportService.currentReport = GenerateReportResponse(
                        reportId: latest.id,
                        currentCity: nil,
                        matches: results
                    )
                    cache.save(reportService.currentReport!, for: .currentReport(userId: userId))
                }
            }

            goToMain()
        } else {
            // Auth check complete — user is not logged in, show getting-started
            currentScreen = .splash
        }
    }

    // MARK: - Sign Out

    /// Signs the user out, clears their local cache, and resets all local state.
    func signOut() async {
        let userId = authService.currentUser?.id.uuidString

        // Sign out from Supabase
        await authService.signOut()

        // Clear per-user cache
        if let userId {
            cache.clearUserCache(userId: userId)
        }

        // Reset all local state
        selectedCityId = nil
        selectedCity = nil
        preferences = .defaults
        onboardingName = ""
        selectedStartType = .cityILove
        searchText = ""
        reportService.currentReport = nil
        reportService.error = nil
        explorationService.explorations = []
        explorationService.error = nil
        savedCitiesService.savedCities = []
        savedCitiesService.savedCityIds = []
        savedCitiesService.cachedUserId = nil
        analytics.userId = nil

        // Navigate to getting-started screen (not loading)
        navigationPath = NavigationPath()
        currentScreen = .splash
    }

    // MARK: - Cache Restore (private)

    /// Restores preferences, current report, explorations, and selected city from disk cache.
    /// Called during `checkExistingSession()` before transitioning to main.
    private func restoreCachedState(userId: String) {
        // Restore preferences
        if let cached = cache.load(
            UserPreferences.self,
            for: .preferences(userId: userId)
        ) {
            preferences = cached.data
        }

        // Restore current report
        reportService.restoreCurrentReport(userId: userId)

        // Restore explorations
        explorationService.restoreFromCache(userId: userId)

        // Restore selected city
        if let cached = cache.load(
            CityWithScores.self,
            for: .selectedCity(userId: userId)
        ) {
            selectedCity = cached.data
            selectedCityId = cached.data.city.id
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
    let safetyPreference: Double
    let commutePreference: Double
    let healthcarePreference: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case startType = "start_type"
        case costPreference = "cost_preference"
        case climatePreference = "climate_preference"
        case culturePreference = "culture_preference"
        case jobMarketPreference = "job_market_preference"
        case safetyPreference = "safety_preference"
        case commutePreference = "commute_preference"
        case healthcarePreference = "healthcare_preference"
    }
}
