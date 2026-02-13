import SwiftUI

// MARK: - Clip Preferences View

struct ClipPreferencesView: View {
    @Environment(ClipCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    var body: some View {
        @Bindable var coord = coordinator

        ScrollView {
            VStack(spacing: TeleportTheme.Spacing.xl) {
                // Hero
                VStack(spacing: TeleportTheme.Spacing.md) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(TeleportTheme.Colors.accent)

                    Text("Find Your City")
                        .font(TeleportTheme.Typography.heroTitle(32))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Text("Tell us what matters most and we'll find cities that match your lifestyle.")
                        .font(TeleportTheme.Typography.body(15))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TeleportTheme.Spacing.xl)
                }
                .padding(.top, TeleportTheme.Spacing.xl)

                // Sliders
                PreferenceSlidersList(preferences: $coord.preferences)
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
            .padding(.bottom, 100)
        }
        .background(TeleportTheme.Colors.background)
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("clip_preferences")
            analytics.track("clip_launched", screen: "clip_preferences")
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("clip_preferences", durationMs: ms, exitType: "advanced")
        }
        .overlay(alignment: .bottom) {
            TeleportButton(title: "Find My Cities", icon: "wand.and.stars") {
                analytics.trackButtonTap("generate", screen: "clip_preferences")
                Task { await coordinator.generate() }
            }
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
