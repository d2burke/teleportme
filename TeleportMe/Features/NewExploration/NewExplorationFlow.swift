import SwiftUI

// MARK: - Flow Steps

private enum ExplorationStep: Int, CaseIterable, Hashable {
    case name = 0
    case method = 1
    case cityPicker = 2
    case tripVibes = 3
    case constraints = 4
    case generating = 5
    case results = 6
}

// MARK: - New Exploration Flow

/// Self-contained modal for creating a new exploration.
/// All state is local — nothing lives on AppCoordinator.
struct NewExplorationFlow: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    private let analytics = AnalyticsService.shared
    @State private var flowStartedAt = Date()

    // Local flow state
    @State private var navigationPath = NavigationPath()
    @State private var title: String = ""
    @State private var startType: StartType = .cityILove
    @State private var selectedCityId: String? = nil
    @State private var selectedCityName: String? = nil
    @State private var preferences: UserPreferences = .defaults
    @State private var signalWeights: [CompassSignal: Double] = [:]
    @State private var tripConstraints: TripConstraints = TripConstraints()
    @State private var generatedResponse: GenerateReportResponse? = nil

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ExplorationNameStepView(
                title: $title,
                onContinue: {
                    navigationPath.append(ExplorationStep.method)
                },
                onDismiss: { dismiss() }
            )
            .navigationDestination(for: ExplorationStep.self) { step in
                switch step {
                case .name:
                    EmptyView() // Root — never navigated to
                case .method:
                    ExplorationMethodStepView(
                        startType: $startType,
                        onContinue: {
                            if startType == .cityILove {
                                navigationPath.append(ExplorationStep.cityPicker)
                            } else {
                                // Compass / vibes mode — go straight to trip vibes
                                navigationPath.append(ExplorationStep.tripVibes)
                            }
                        }
                    )
                case .cityPicker:
                    ExplorationCityPickerStepView(
                        selectedCityId: $selectedCityId,
                        selectedCityName: $selectedCityName,
                        onContinue: {
                            // Pre-load signal weights from the selected city
                            if let cityId = selectedCityId {
                                Task {
                                    if let city = await coordinator.cityService.getCityWithScores(cityId: cityId) {
                                        signalWeights = HeadingEngine.signalWeights(fromCityScores: city.scores)
                                    }
                                }
                            }
                            navigationPath.append(ExplorationStep.tripVibes)
                        },
                        onSkip: {
                            selectedCityId = nil
                            selectedCityName = nil
                            navigationPath.append(ExplorationStep.tripVibes)
                        }
                    )
                case .tripVibes:
                    TripVibesView(
                        signalWeights: $signalWeights,
                        onContinue: {
                            navigationPath.append(ExplorationStep.constraints)
                        },
                        onBack: {
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
                    )
                case .constraints:
                    ConstraintsView(
                        constraints: $tripConstraints,
                        onContinue: {
                            navigationPath.append(ExplorationStep.generating)
                        },
                        onBack: {
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                        }
                    )
                case .generating:
                    ExplorationGeneratingStepView(
                        title: effectiveTitle,
                        startType: startType,
                        baselineCityId: selectedCityId,
                        preferences: preferences,
                        compassVibes: compassVibesDict,
                        compassConstraints: tripConstraints.hasAny ? tripConstraints : nil,
                        onComplete: { response in
                            generatedResponse = response

                            // Evolve the user's heading with these trip vibes
                            Task { await evolveHeading() }

                            // Replace generating with results (no back swipe to loading)
                            if !navigationPath.isEmpty {
                                navigationPath.removeLast()
                            }
                            navigationPath.append(ExplorationStep.results)
                        },
                        onError: { _ in
                            // Stay on generating view — it has a retry button
                        }
                    )
                case .results:
                    ExplorationResultsStepView(
                        response: generatedResponse,
                        explorationTitle: effectiveTitle,
                        onDone: { dismiss() }
                    )
                }
            }
        }
        .interactiveDismissDisabled(generatedResponse != nil) // Don't dismiss after results
        .onAppear {
            flowStartedAt = Date()
            analytics.track("exploration_flow_started", screen: "new_exploration_name", properties: ["source": "modal"])
            // Pre-fill with user's saved preferences if available
            preferences = coordinator.preferences
            // Pre-load signal weights from saved heading
            if let savedWeights = coordinator.preferences.signalWeights {
                signalWeights = HeadingEngine.heading(fromRaw: savedWeights).topSignals.isEmpty
                    ? [:]
                    : Dictionary(uniqueKeysWithValues: savedWeights.compactMap { key, value in
                        guard let signal = CompassSignal(rawValue: key) else { return nil }
                        return (signal, value)
                    })
            }
        }
        .onDisappear {
            if generatedResponse != nil {
                let ms = Int(Date().timeIntervalSince(flowStartedAt) * 1000)
                analytics.track("exploration_flow_completed", screen: "new_exploration_results", properties: [
                    "total_duration_ms": String(ms)
                ])
            } else {
                let ms = Int(Date().timeIntervalSince(flowStartedAt) * 1000)
                analytics.track("exploration_flow_abandoned", screen: "new_exploration_name", properties: [
                    "duration_ms": String(ms)
                ])
            }
        }
    }

    // MARK: - Helpers

    private var compassVibesDict: [String: Double]? {
        let active = signalWeights.filter { $0.value > 0 }
        return active.isEmpty ? nil : Dictionary(uniqueKeysWithValues: active.map { ($0.key.rawValue, $0.value) })
    }

    private var effectiveTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            // Use heading name if available
            let heading = HeadingEngine.heading(from: signalWeights)
            if !heading.topSignals.isEmpty {
                return "\(heading.emoji) \(heading.name) Trip"
            }
            if startType == .vibes {
                return "Compass Exploration"
            }
            if let cityName = selectedCityName {
                return "\(cityName) Exploration"
            }
            return "New Exploration"
        }
        return trimmed
    }

    /// After a successful exploration, blend trip vibes into the user's persistent heading.
    private func evolveHeading() async {
        guard !signalWeights.isEmpty else { return }

        let existing = coordinator.preferences.signalWeights ?? [:]
        let evolved = HeadingEngine.evolveHeading(existing: existing, tripVibes: signalWeights)

        coordinator.preferences.signalWeights = evolved
        await coordinator.savePreferences()
    }
}
