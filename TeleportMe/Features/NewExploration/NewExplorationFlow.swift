import SwiftUI

// MARK: - Flow Steps

private enum ExplorationStep: Int, CaseIterable, Hashable {
    case name = 0
    case method = 1
    case cityPicker = 2
    case preferences = 3
    case generating = 4
    case results = 5
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
                                // For vibes/words, skip city picker (coming soon)
                                navigationPath.append(ExplorationStep.preferences)
                            }
                        }
                    )
                case .cityPicker:
                    ExplorationCityPickerStepView(
                        selectedCityId: $selectedCityId,
                        selectedCityName: $selectedCityName,
                        onContinue: {
                            navigationPath.append(ExplorationStep.preferences)
                        },
                        onSkip: {
                            selectedCityId = nil
                            selectedCityName = nil
                            navigationPath.append(ExplorationStep.preferences)
                        }
                    )
                case .preferences:
                    ExplorationPreferencesStepView(
                        preferences: $preferences,
                        onContinue: {
                            navigationPath.append(ExplorationStep.generating)
                        }
                    )
                case .generating:
                    ExplorationGeneratingStepView(
                        title: effectiveTitle,
                        startType: startType,
                        baselineCityId: selectedCityId,
                        preferences: preferences,
                        onComplete: { response in
                            generatedResponse = response
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

    private var effectiveTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if let cityName = selectedCityName {
                return "\(cityName) Exploration"
            }
            return "New Exploration"
        }
        return trimmed
    }
}
