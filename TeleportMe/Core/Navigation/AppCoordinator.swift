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
    case profile
    case search
}

/// Routes the app can handle via Universal Links or custom URL scheme.
/// Supports: https://getteleport.me/profile  AND  teleportme://profile
enum DeepLink {
    case authCallback(URL)   // /auth/callback – Supabase PKCE exchange
    case tab(AppTab)         // /profile, /discover, /search

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
    case citySearch = 3        // only for .cityILove
    case cityBaseline = 4      // only for .cityILove
    case tripVibes = 5         // Trip Compass — signal grid
    case constraints = 6       // Trip Compass — constraints
    case generating = 7
    case recommendations = 8

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
    var selectedVibeIds: Set<String> = []

    // Compass state (for onboarding flow)
    var signalWeights: [CompassSignal: Double] = [:]
    var tripConstraints: TripConstraints = TripConstraints()

    // MARK: - Navigation

    func startOnboarding() {
        navigationPath = NavigationPath()
        currentScreen = .onboarding
    }

    func advanceOnboarding(from step: OnboardingStep) {
        // Persist preferences to Supabase when leaving the constraints step
        if step == .constraints {
            // Save signal weights to preferences (server handles scoring)
            let rawWeights = Dictionary(uniqueKeysWithValues: signalWeights.map { ($0.key.rawValue, $0.value) })
            preferences.signalWeights = rawWeights
            Task { await savePreferences() }
        }

        if step == .generating {
            // Replace generating with recommendations so user can't
            // swipe back to the loading screen
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
            navigationPath.append(OnboardingStep.recommendations)
        } else if step == .startType {
            // Conditional routing based on selected start type
            if selectedStartType == .vibes {
                // Compass mode — go directly to trip vibes
                navigationPath.append(OnboardingStep.tripVibes)
            } else {
                navigationPath.append(OnboardingStep.citySearch)
            }
        } else if step == .cityBaseline {
            // After baseline city, go to trip vibes (pre-loaded from city scores)
            if let city = selectedCity {
                signalWeights = HeadingEngine.signalWeights(fromCityScores: city.scores)
            }
            navigationPath.append(OnboardingStep.tripVibes)
        } else if step == .tripVibes {
            navigationPath.append(OnboardingStep.constraints)
        } else if step == .constraints {
            navigationPath.append(OnboardingStep.generating)
        } else {
            guard let next = step.next else { return }
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
            healthcarePreference: preferences.healthcarePreference,
            selectedVibeTags: preferences.selectedVibeTags,
            signalWeights: preferences.signalWeights
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

            // Load cities and scores (will use disk cache if available)
            await cityService.fetchAllCities()
            await cityService.fetchAllScores()

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
        selectedVibeIds = []
        signalWeights = [:]
        tripConstraints = TripConstraints()
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
    let selectedVibeTags: [String]?
    let signalWeights: [String: Double]?

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
        case selectedVibeTags = "selected_vibe_tags"
        case signalWeights = "signal_weights"
    }
}
