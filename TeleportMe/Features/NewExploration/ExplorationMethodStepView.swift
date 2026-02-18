import SwiftUI

// MARK: - Exploration Method Step

/// Reuses `StartTypeCard` from the onboarding flow for a consistent look-and-feel.
/// Single tap selects the method AND advances — no separate "Continue" button needed.
struct ExplorationMethodStepView: View {
    @Binding var startType: StartType
    let onContinue: () -> Void

    private let options: [(StartType, String, String, String, Bool)] = [
        (.cityILove, "A City I Love", "Start from a city you know and find similar ones that match your vibe.", "building.2", true),
        (.vibes, "Compass", "Set your signals and constraints to find cities that match your vibe.", "safari", true),
        (.myWords, "My Own Words", "Describe your ideal city in your own words and let AI find it.", "text.quote", false),
    ]

    @State private var appeared = false

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            Spacer()

            Text("How do you want\nto explore?")
                .font(TeleportTheme.Typography.title(24))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            VStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(Array(options.enumerated()), id: \.0) { index, option in
                    StartTypeCard(
                        type: option.0,
                        title: option.1,
                        description: option.2,
                        icon: option.3,
                        isSelected: startType == option.0
                    ) {
                        guard option.4 else { return } // Skip unavailable (myWords)
                        startType = option.0
                        onContinue()
                    }
                    .opacity(option.4 ? 1 : 0.5)
                    .disabled(!option.4)
                    .overlay(alignment: .topTrailing) {
                        if !option.4 {
                            Text("Coming Soon")
                                .font(TeleportTheme.Typography.caption(11))
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                .padding(.horizontal, TeleportTheme.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(TeleportTheme.Colors.surfaceElevated)
                                .clipShape(Capsule())
                                .padding(TeleportTheme.Spacing.sm)
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                        value: appeared
                    )
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)

            Spacer()
        }
        .background(TeleportTheme.Colors.backgroundElevated)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }
}
