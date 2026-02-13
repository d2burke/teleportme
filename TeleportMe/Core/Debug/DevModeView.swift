import SwiftUI

#if DEBUG
struct DevModeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Auth Bypass
                Section {
                    @Bindable var coord = coordinator

                    Toggle("Skip Auth (Preview Mode)", isOn: $coord.previewMode)
                        .tint(TeleportTheme.Colors.accent)

                    Text("When enabled, sign-up is skipped and you can test the full onboarding flow without creating Supabase accounts.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Authentication")
                }

                // MARK: - Jump to Screen
                Section {
                    Button("Splash") {
                        coordinator.currentScreen = .splash
                        dismiss()
                    }

                    ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                        Button(stepName(step)) {
                            jumpTo(step)
                            dismiss()
                        }
                    }

                    Button("Main (Tabs)") {
                        coordinator.currentScreen = .main
                        dismiss()
                    }
                } header: {
                    Text("Jump to Screen")
                } footer: {
                    Text("Navigates directly to a screen. Some screens need data — mock data will be loaded automatically.")
                }

                // MARK: - Mock Data
                Section {
                    Button("Load Mock City (San Francisco)") {
                        loadMockCity()
                    }

                    Button("Load Mock Report (3 cities)") {
                        loadMockReport()
                    }
                } header: {
                    Text("Mock Data")
                }

                // MARK: - Feature Flags
                Section {
                    // Add future feature flags here as toggles, e.g.:
                    // Toggle("New City Detail View", isOn: $coord.featureFlags.newCityDetail)
                    //     .tint(TeleportTheme.Colors.accent)
                    Text("No feature flags configured yet. Add toggles here for A/B testing and staged rollouts.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Feature Flags")
                }

                // MARK: - State Info
                Section {
                    LabeledContent("Current Screen", value: screenName)
                    LabeledContent("Auth Status", value: coordinator.authService.isAuthenticated ? "Signed In" : "Not Signed In")
                    LabeledContent("Selected City", value: coordinator.selectedCity?.city.name ?? "None")
                    LabeledContent("Report Loaded", value: coordinator.reportService.currentReport != nil ? "Yes" : "No")
                    LabeledContent("Preview Mode", value: coordinator.previewMode ? "ON" : "OFF")
                } header: {
                    Text("Current State")
                }
            }
            .navigationTitle("Dev Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(TeleportTheme.Colors.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers

    private var screenName: String {
        switch coordinator.currentScreen {
        case .loading: return "Loading"
        case .splash: return "Splash"
        case .onboarding: return "Onboarding (path depth: \(coordinator.navigationPath.count))"
        case .main: return "Main"
        }
    }

    private func stepName(_ step: OnboardingStep) -> String {
        switch step {
        case .name: return "Name Input"
        case .signUp: return "Sign Up"
        case .startType: return "Start Type"
        case .citySearch: return "City Search"
        case .cityBaseline: return "City Baseline"
        case .preferences: return "Preferences"
        case .generating: return "Generating"
        case .recommendations: return "Recommendations"
        }
    }

    private func jumpTo(_ step: OnboardingStep) {
        // Pre-populate data for screens that need it
        switch step {
        case .cityBaseline, .preferences, .generating, .recommendations:
            if coordinator.selectedCity == nil {
                loadMockCity()
            }
            if step == .recommendations && coordinator.reportService.currentReport == nil {
                loadMockReport()
            }
        default:
            break
        }

        // Build navigation path up to the target step
        var path = NavigationPath()
        for s in OnboardingStep.allCases where s.rawValue > 0 && s.rawValue <= step.rawValue {
            path.append(s)
        }
        coordinator.navigationPath = path
        coordinator.currentScreen = .onboarding
    }

    private func loadMockCity() {
        let mockCoord = PreviewHelpers.makeCoordinator()
        coordinator.selectedCity = mockCoord.selectedCity
        coordinator.selectedCityId = mockCoord.selectedCityId
        coordinator.onboardingName = mockCoord.onboardingName
    }

    private func loadMockReport() {
        let mockCoord = PreviewHelpers.makeCoordinatorWithReport()
        coordinator.selectedCity = mockCoord.selectedCity
        coordinator.selectedCityId = mockCoord.selectedCityId
        coordinator.onboardingName = mockCoord.onboardingName
        coordinator.reportService.currentReport = mockCoord.reportService.currentReport
    }
}

#Preview {
    DevModeView()
        .environment(PreviewHelpers.makeCoordinator())
}
#endif
