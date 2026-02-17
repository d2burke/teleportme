import SwiftUI

// MARK: - Exploration Preferences Step

struct ExplorationPreferencesStepView: View {
    @Binding var preferences: UserPreferences
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                // Title
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text("What matters most?")
                        .font(TeleportTheme.Typography.title(24))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Text("Adjust these sliders to match your priorities. Tap \(Image(systemName: "info.circle")) to learn more.")
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)

                // Preference sliders
                PreferenceSlidersList(preferences: $preferences)
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
            .padding(.bottom, 100)
        }
        .background(TeleportTheme.Colors.backgroundElevated)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            TeleportButton(title: "Find My Cities", icon: "wand.and.stars") {
                onContinue()
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .padding(.bottom, TeleportTheme.Spacing.lg)
            .background(
                LinearGradient(
                    colors: [TeleportTheme.Colors.backgroundElevated.opacity(0), TeleportTheme.Colors.backgroundElevated],
                    startPoint: .top,
                    endPoint: .center
                )
            )
        }
    }
}
