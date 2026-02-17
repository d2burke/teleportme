import SwiftUI

// MARK: - Clip Screen State

enum ClipScreen: Hashable {
    case startType
    case tripVibes
    case constraints
    case generating
    case results
}

// MARK: - Clip Coordinator

@Observable
final class ClipCoordinator {
    var currentScreen: ClipScreen = .startType

    // Services (shared with main app)
    let cityService = CityService()
    let explorationService = ExplorationService()

    // Local preferences for the clip
    var preferences: UserPreferences = .defaults
    var selectedStartType: StartType = .vibes  // Default to compass for App Clip
    var signalWeights: [CompassSignal: Double] = [:]
    var tripConstraints: TripConstraints = TripConstraints()
    var generatedResponse: GenerateReportResponse?
    var error: String?

    // MARK: - Navigation

    func advanceFromStartType() {
        currentScreen = .tripVibes
    }

    func advanceFromTripVibes() {
        currentScreen = .constraints
    }

    func advanceFromConstraints() {
        Task { await generate() }
    }

    func goBackFromTripVibes() {
        currentScreen = .startType
    }

    func goBackFromConstraints() {
        currentScreen = .tripVibes
    }

    // MARK: - Generate

    func generate() async {
        currentScreen = .generating
        error = nil

        // Infer preferences from signal weights for backward compat
        let inferred = HeadingEngine.inferPreferences(from: signalWeights)
        preferences = UserPreferences(
            costPreference: inferred.cost,
            climatePreference: inferred.climate,
            culturePreference: inferred.culture,
            jobMarketPreference: inferred.jobMarket,
            safetyPreference: inferred.safety,
            commutePreference: inferred.commute,
            healthcarePreference: inferred.healthcare
        )

        // Build compass vibes dict
        let compassVibes: [String: Double] = Dictionary(
            uniqueKeysWithValues: signalWeights
                .filter { $0.value > 0 }
                .map { ($0.key.rawValue, $0.value) }
        )

        // Build exploration title from heading
        let heading = HeadingEngine.heading(from: signalWeights)
        let title = heading.topSignals.isEmpty
            ? "Quick Exploration"
            : "\(heading.emoji) \(heading.name) Trip"

        do {
            let response = try await explorationService.generateExploration(
                title: title,
                startType: selectedStartType,
                baselineCityId: nil,
                preferences: preferences,
                compassVibes: compassVibes.isEmpty ? nil : compassVibes,
                compassConstraints: tripConstraints.hasAny ? tripConstraints : nil,
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
