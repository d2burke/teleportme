import Testing
import Foundation
import SwiftUI
@testable import TeleportMe

// MARK: - OnboardingStep Tests

struct OnboardingStepTests {

    @Test func stepRawValues() {
        #expect(OnboardingStep.name.rawValue == 0)
        #expect(OnboardingStep.signUp.rawValue == 1)
        #expect(OnboardingStep.startType.rawValue == 2)
        #expect(OnboardingStep.citySearch.rawValue == 3)
        #expect(OnboardingStep.cityBaseline.rawValue == 4)
        #expect(OnboardingStep.tripVibes.rawValue == 5)
        #expect(OnboardingStep.constraints.rawValue == 6)
        #expect(OnboardingStep.generating.rawValue == 7)
        #expect(OnboardingStep.recommendations.rawValue == 8)
    }

    @Test func allCasesCount() {
        #expect(OnboardingStep.allCases.count == 9)
    }

    @Test func nextStep_fromName() {
        #expect(OnboardingStep.name.next == .signUp)
    }

    @Test func nextStep_fromRecommendations() {
        #expect(OnboardingStep.recommendations.next == nil)
    }

    @Test func previousStep_fromSignUp() {
        #expect(OnboardingStep.signUp.previous == .name)
    }

    @Test func previousStep_fromName() {
        #expect(OnboardingStep.name.previous == nil)
    }

    @Test func nextPreviousRoundTrip() {
        for step in OnboardingStep.allCases {
            if let next = step.next {
                #expect(next.previous == step, "\(step).next.previous should equal \(step)")
            }
        }
    }
}

// MARK: - DeepLink Tests

struct DeepLinkTests {

    @Test func httpsProfileLink() {
        let url = URL(string: "https://getteleport.me/profile")!
        let link = DeepLink(url: url)
        if case .tab(let tab) = link {
            #expect(tab == .profile)
        } else {
            #expect(Bool(false), "Expected .tab(.profile)")
        }
    }

    @Test func httpsDiscoverLink() {
        let url = URL(string: "https://getteleport.me/discover")!
        let link = DeepLink(url: url)
        if case .tab(let tab) = link {
            #expect(tab == .discover)
        } else {
            #expect(Bool(false), "Expected .tab(.discover)")
        }
    }

    @Test func httpsSavedLink() {
        let url = URL(string: "https://getteleport.me/saved")!
        let link = DeepLink(url: url)
        if case .tab(let tab) = link {
            #expect(tab == .saved)
        } else {
            #expect(Bool(false), "Expected .tab(.saved)")
        }
    }

    @Test func httpsMapLink() {
        let url = URL(string: "https://getteleport.me/map")!
        let link = DeepLink(url: url)
        if case .tab(let tab) = link {
            #expect(tab == .map)
        } else {
            #expect(Bool(false), "Expected .tab(.map)")
        }
    }

    @Test func httpsSearchLink() {
        let url = URL(string: "https://getteleport.me/search")!
        let link = DeepLink(url: url)
        if case .tab(let tab) = link {
            #expect(tab == .search)
        } else {
            #expect(Bool(false), "Expected .tab(.search)")
        }
    }

    @Test func httpsAuthCallbackLink() {
        let url = URL(string: "https://getteleport.me/auth/callback?code=abc123")!
        let link = DeepLink(url: url)
        if case .authCallback(let cbURL) = link {
            #expect(cbURL == url)
        } else {
            #expect(Bool(false), "Expected .authCallback")
        }
    }

    @Test func customSchemeProfileLink() {
        let url = URL(string: "teleportme://profile")!
        let link = DeepLink(url: url)
        if case .tab(let tab) = link {
            #expect(tab == .profile)
        } else {
            #expect(Bool(false), "Expected .tab(.profile) for custom scheme")
        }
    }

    @Test func customSchemeDiscoverLink() {
        let url = URL(string: "teleportme://discover")!
        let link = DeepLink(url: url)
        if case .tab(let tab) = link {
            #expect(tab == .discover)
        } else {
            #expect(Bool(false), "Expected .tab(.discover) for custom scheme")
        }
    }

    @Test func unknownPathReturnsNil() {
        let url = URL(string: "https://getteleport.me/unknown")!
        let link = DeepLink(url: url)
        #expect(link == nil)
    }

    @Test func emptyPathReturnsNil() {
        let url = URL(string: "https://getteleport.me/")!
        let link = DeepLink(url: url)
        #expect(link == nil)
    }

    @Test func customSchemeUnknownReturnsNil() {
        let url = URL(string: "teleportme://foobar")!
        let link = DeepLink(url: url)
        #expect(link == nil)
    }
}

// MARK: - AppScreen & AppTab Tests

struct AppScreenTests {

    @Test func appTabRawValues() {
        #expect(AppTab.discover.rawValue == "discover")
        #expect(AppTab.saved.rawValue == "saved")
        #expect(AppTab.map.rawValue == "map")
        #expect(AppTab.profile.rawValue == "profile")
        #expect(AppTab.search.rawValue == "search")
    }
}

// MARK: - AppCoordinator Tests

@MainActor
struct AppCoordinatorTests {

    // MARK: - Initial State

    @Test func initialState() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        #expect(coordinator.currentScreen == .loading)
        #expect(coordinator.selectedTab == .discover)
        #expect(coordinator.onboardingName == "")
        #expect(coordinator.selectedStartType == .cityILove)
        #expect(coordinator.selectedCityId == nil)
        #expect(coordinator.selectedCity == nil)
        #expect(coordinator.signalWeights.isEmpty)
        #expect(coordinator.tripConstraints.hasAny == false)
        #expect(coordinator.searchText == "")
        #expect(coordinator.showNewExplorationModal == false)
    }

    @Test func initialPreferences() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        let prefs = coordinator.preferences
        #expect(prefs.costPreference == 5.0)
        #expect(prefs.climatePreference == 5.0)
        #expect(prefs.culturePreference == 5.0)
        #expect(prefs.jobMarketPreference == 5.0)
        #expect(prefs.safetyPreference == 5.0)
        #expect(prefs.commutePreference == 5.0)
        #expect(prefs.healthcarePreference == 5.0)
    }

    // MARK: - Navigation

    @Test func startOnboarding_setsScreen() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.startOnboarding()
        #expect(coordinator.currentScreen == .onboarding)
    }

    @Test func startOnboarding_clearsNavigationPath() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.navigationPath.append(OnboardingStep.name)
        coordinator.startOnboarding()
        #expect(coordinator.navigationPath.isEmpty)
    }

    @Test func completeOnboarding_goesToMain() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.currentScreen = .onboarding
        coordinator.completeOnboarding()
        #expect(coordinator.currentScreen == .main)
        #expect(coordinator.navigationPath.isEmpty)
    }

    @Test func goToMain_setsMainScreen() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.currentScreen = .loading
        coordinator.goToMain()
        #expect(coordinator.currentScreen == .main)
    }

    // MARK: - advanceOnboarding routing

    @Test func advanceFromStartType_vibes_goesToTripVibes() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.selectedStartType = .vibes
        coordinator.advanceOnboarding(from: .startType)
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func advanceFromStartType_cityILove_goesToCitySearch() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.selectedStartType = .cityILove
        coordinator.advanceOnboarding(from: .startType)
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func advanceFromCityBaseline_goesToTripVibes() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.advanceOnboarding(from: .cityBaseline)
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func advanceFromTripVibes_goesToConstraints() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.advanceOnboarding(from: .tripVibes)
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func advanceFromConstraints_goesToGenerating() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.advanceOnboarding(from: .constraints)
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func advanceFromName_goesToSignUp() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.advanceOnboarding(from: .name)
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func advanceFromGenerating_replacesWithRecommendations() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        // Simulate being on the generating step
        coordinator.navigationPath.append(OnboardingStep.generating)
        coordinator.advanceOnboarding(from: .generating)
        // Should have removed generating and appended recommendations
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func advanceFromRecommendations_noNext() {
        // recommendations is the last step, next is nil
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        let countBefore = coordinator.navigationPath.count
        coordinator.advanceOnboarding(from: .recommendations)
        // No next step — path should not change
        #expect(coordinator.navigationPath.count == countBefore)
    }

    // MARK: - goBackOnboarding

    @Test func goBack_removesLastFromPath() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.navigationPath.append(OnboardingStep.tripVibes)
        coordinator.navigationPath.append(OnboardingStep.constraints)
        coordinator.goBackOnboarding(from: .constraints)
        #expect(coordinator.navigationPath.count == 1)
    }

    @Test func goBack_emptyPath_doesNotCrash() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        // Should not crash when path is empty
        coordinator.goBackOnboarding(from: .name)
        #expect(coordinator.navigationPath.isEmpty)
    }

    // MARK: - Deep Link Handling

    @Test func handleDeepLink_tabOnMain_switchesTab() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.currentScreen = .main
        coordinator.selectedTab = .discover
        let url = URL(string: "https://getteleport.me/profile")!
        coordinator.handleDeepLink(url)
        #expect(coordinator.selectedTab == .profile)
    }

    @Test func handleDeepLink_tabNotOnMain_queuesTab() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.currentScreen = .onboarding
        let url = URL(string: "https://getteleport.me/saved")!
        coordinator.handleDeepLink(url)
        // Tab should be queued even if not on main
        #expect(coordinator.selectedTab == .saved)
    }

    @Test func handleDeepLink_unknownURL_noChange() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.currentScreen = .main
        coordinator.selectedTab = .discover
        let url = URL(string: "https://getteleport.me/unknown")!
        coordinator.handleDeepLink(url)
        #expect(coordinator.selectedTab == .discover)
    }

    @Test func handleDeepLink_customScheme_switchesTab() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.currentScreen = .main
        let url = URL(string: "teleportme://map")!
        coordinator.handleDeepLink(url)
        #expect(coordinator.selectedTab == .map)
    }

    // MARK: - State Reset (signOut behavior)

    @Test func signOutResetsState() async {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true

        // Set up some state
        coordinator.signalWeights = [.climate: 3.0, .cost: 2.0]
        coordinator.tripConstraints = TripConstraints(travelDistance: .short)
        coordinator.preferences = UserPreferences(
            costPreference: 8.0,
            climatePreference: 7.0
        )
        coordinator.onboardingName = "Test User"
        coordinator.selectedStartType = .vibes
        coordinator.selectedCityId = "city-123"
        coordinator.searchText = "Barcelona"
        coordinator.currentScreen = .main

        await coordinator.signOut()

        #expect(coordinator.signalWeights.isEmpty)
        #expect(coordinator.tripConstraints.hasAny == false)
        #expect(coordinator.preferences.costPreference == 5.0, "Should reset to defaults")
        #expect(coordinator.onboardingName == "")
        #expect(coordinator.selectedStartType == .cityILove)
        #expect(coordinator.selectedCityId == nil)
        #expect(coordinator.selectedCity == nil)
        #expect(coordinator.searchText == "")
        #expect(coordinator.currentScreen == .splash)
        #expect(coordinator.navigationPath.isEmpty)
    }

    // MARK: - advanceOnboarding infers preferences from signal weights

    @Test func advanceFromConstraints_infersPreferences() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        coordinator.signalWeights = [
            .climate: 3.0,
            .cost: 2.0,
            .safety: 1.0,
        ]
        let oldCost = coordinator.preferences.costPreference
        coordinator.advanceOnboarding(from: .constraints)
        // After advancing from constraints, preferences should be inferred from signal weights
        // The cost preference should change from the default 5.0
        #expect(coordinator.preferences.costPreference != oldCost, "Cost preference should be inferred from signal weights")
    }

    // MARK: - Preview Mode

    @Test func previewModePreventsAuthCalls() async {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        // checkExistingSession should return without changing screen in preview mode
        await coordinator.checkExistingSession()
        // In preview mode, checkExistingSession returns early without transitioning
        #expect(coordinator.currentScreen == .loading)
    }

    // MARK: - advanceFromCityBaseline loads signal weights

    @Test func advanceFromCityBaseline_withCity_loadsSignalWeights() {
        let coordinator = AppCoordinator()
        coordinator.previewMode = true
        // Set up a city with scores
        let city = CityWithScores(
            city: City(
                id: "test-id",
                name: "Test City",
                fullName: "Test City, Country",
                country: "Testland",
                continent: "Europe",
                latitude: 40.0,
                longitude: -74.0,
                population: 1_000_000,
                teleportCityScore: 75.0,
                summary: "A great city",
                imageUrl: "https://example.com/city.jpg"
            ),
            scores: [
                "Environmental Quality": 8.0,
                "Cost of Living": 6.0,
                "Safety": 9.0,
            ]
        )
        coordinator.selectedCity = city
        coordinator.advanceOnboarding(from: .cityBaseline)
        // Signal weights should be populated from city scores
        #expect(!coordinator.signalWeights.isEmpty, "Signal weights should be loaded from city scores")
    }
}
