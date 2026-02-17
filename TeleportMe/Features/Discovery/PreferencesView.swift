import SwiftUI

struct PreferencesView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var isSaving = false
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    var body: some View {
        @Bindable var coord = coordinator

        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                // Title
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text("Your Lifestyle Match")
                        .font(TeleportTheme.Typography.title(24))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Text("Prioritize the factors that matter most for your next home. Tap \(Image(systemName: "info.circle")) to learn more.")
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)

                // Preference sliders
                PreferenceSlidersList(preferences: $coord.preferences)
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                    .allowsHitTesting(!isSaving)
                    .opacity(isSaving ? 0.6 : 1.0)
            }
            .padding(.bottom, 100) // Space for button
        }
        .background(TeleportTheme.Colors.background)
        .navigationTitle("Personalize")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("preferences")
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("preferences", durationMs: ms, exitType: "advanced")
        }
        .overlay(alignment: .bottom) {
            // Fixed CTA at bottom
            TeleportButton(title: "Find My Cities", icon: "arrow.right", isLoading: isSaving) {
                analytics.trackButtonTap("continue", screen: "preferences")
                let prefs = coordinator.preferences
                analytics.track("onboarding_step_completed", screen: "preferences", properties: [
                    "step": "preferences",
                    "duration_ms": String(Int(Date().timeIntervalSince(screenEnteredAt) * 1000)),
                    "cost": String(format: "%.1f", prefs.costPreference),
                    "climate": String(format: "%.1f", prefs.climatePreference),
                    "culture": String(format: "%.1f", prefs.culturePreference),
                    "jobs": String(format: "%.1f", prefs.jobMarketPreference),
                    "safety": String(format: "%.1f", prefs.safetyPreference),
                    "commute": String(format: "%.1f", prefs.commutePreference),
                    "healthcare": String(format: "%.1f", prefs.healthcarePreference),
                ])
                isSaving = true
                coordinator.advanceOnboarding(from: .constraints)
            }
            .disabled(isSaving)
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .padding(.bottom, TeleportTheme.Spacing.lg)
            .background(
                LinearGradient(
                    colors: [TeleportTheme.Colors.background.opacity(0), TeleportTheme.Colors.background],
                    startPoint: .top,
                    endPoint: .center
                )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        PreferencesView()
    }
}
