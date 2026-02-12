import SwiftUI

struct PreferencesView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var appeared = false
    @State private var isSaving = false

    var body: some View {
        @Bindable var coord = coordinator

        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                // Title
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text("Your Lifestyle Match")
                        .font(TeleportTheme.Typography.title(24))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Text("Prioritize the factors that matter most for your next home.")
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)

                // Preference sliders
                VStack(spacing: TeleportTheme.Spacing.md) {
                    PreferenceSliderCard(
                        icon: "banknote",
                        title: "Cost of Living",
                        lowLabel: "Lower",
                        highLabel: "Higher",
                        value: $coord.preferences.costPreference
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5).delay(0.0), value: appeared)

                    PreferenceSliderCard(
                        icon: "thermometer.sun",
                        title: "Climate",
                        lowLabel: "Colder",
                        highLabel: "Warmer",
                        value: $coord.preferences.climatePreference
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5).delay(0.1), value: appeared)

                    PreferenceSliderCard(
                        icon: "theatermasks",
                        title: "Culture & Lifestyle",
                        lowLabel: "Chill",
                        highLabel: "Vibrant",
                        value: $coord.preferences.culturePreference
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5).delay(0.2), value: appeared)

                    PreferenceSliderCard(
                        icon: "briefcase",
                        title: "Job Market",
                        lowLabel: "Niche",
                        highLabel: "Growth",
                        value: $coord.preferences.jobMarketPreference
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5).delay(0.3), value: appeared)
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .allowsHitTesting(!isSaving)
                .opacity(isSaving ? 0.6 : 1.0)
            }
            .padding(.bottom, 100) // Space for button
        }
        .background(TeleportTheme.Colors.background)
        .navigationTitle("Personalize")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            // Fixed CTA at bottom
            TeleportButton(title: "Find My Cities", icon: "arrow.right", isLoading: isSaving) {
                isSaving = true
                coordinator.advanceOnboarding(from: .preferences)
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
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        PreferencesView()
    }
}
