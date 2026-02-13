import SwiftUI

// MARK: - Clip Screen State

enum ClipScreen {
    case preferences
    case generating
    case results
}

// MARK: - Clip Coordinator

@Observable
final class ClipCoordinator {
    var currentScreen: ClipScreen = .preferences

    // Services (shared with main app)
    let cityService = CityService()
    let explorationService = ExplorationService()

    // Local preferences for the clip
    var preferences: UserPreferences = .defaults
    var generatedResponse: GenerateReportResponse?
    var error: String?

    // MARK: - Generate

    func generate() async {
        currentScreen = .generating
        error = nil

        do {
            let response = try await explorationService.generateExploration(
                title: "Quick Exploration",
                startType: .cityILove,
                baselineCityId: nil,
                preferences: preferences,
                userId: nil  // No auth in clip
            )
            generatedResponse = response
            currentScreen = .results
        } catch {
            self.error = error.localizedDescription
            print("Clip generation failed: \(error)")
        }
    }
}
