import SwiftUI

// MARK: - Exploration Method Step

struct ExplorationMethodStepView: View {
    @Binding var startType: StartType
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: TeleportTheme.Spacing.xl) {
                // Header
                VStack(spacing: TeleportTheme.Spacing.sm) {
                    Text("How do you want\nto explore?")
                        .font(TeleportTheme.Typography.title(26))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Choose how you'd like to discover new cities.")
                        .font(TeleportTheme.Typography.body(15))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, TeleportTheme.Spacing.xl)

                // Method cards
                VStack(spacing: TeleportTheme.Spacing.md) {
                    MethodCard(
                        icon: "heart.fill",
                        title: "A City I Love",
                        description: "Start from a city you know and find similar ones that match your vibe.",
                        isSelected: startType == .cityILove,
                        isAvailable: true
                    ) {
                        startType = .cityILove
                    }

                    MethodCard(
                        icon: "waveform",
                        title: "Vibes",
                        description: "Choose mood tags and aesthetics to find cities that feel right.",
                        isSelected: startType == .vibes,
                        isAvailable: false
                    ) {
                        // Coming soon
                    }

                    MethodCard(
                        icon: "text.quote",
                        title: "My Own Words",
                        description: "Describe your ideal city in your own words and let AI find it.",
                        isSelected: startType == .myWords,
                        isAvailable: false
                    ) {
                        // Coming soon
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
            }
            .padding(.bottom, 100) // Space for button
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            TeleportButton(title: "Continue", icon: "arrow.right") {
                onContinue()
            }
            .disabled(startType != .cityILove) // Only city_i_love is available
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

// MARK: - Method Card

private struct MethodCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(
                        isAvailable
                            ? (isSelected ? TeleportTheme.Colors.accent : TeleportTheme.Colors.textSecondary)
                            : TeleportTheme.Colors.textTertiary
                    )
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    HStack {
                        Text(title)
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(
                                isAvailable
                                    ? TeleportTheme.Colors.textPrimary
                                    : TeleportTheme.Colors.textTertiary
                            )

                        if !isAvailable {
                            Text("Coming Soon")
                                .font(TeleportTheme.Typography.caption(11))
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                .padding(.horizontal, TeleportTheme.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(TeleportTheme.Colors.surfaceElevated)
                                .clipShape(Capsule())
                        }
                    }

                    Text(description)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(
                            isAvailable
                                ? TeleportTheme.Colors.textSecondary
                                : TeleportTheme.Colors.textTertiary
                        )
                        .lineLimit(2)
                }

                Spacer()

                if isAvailable {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            isSelected ? TeleportTheme.Colors.accent : TeleportTheme.Colors.border
                        )
                }
            }
            .padding(TeleportTheme.Spacing.md)
            .background(TeleportTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                    .strokeBorder(
                        isSelected && isAvailable
                            ? TeleportTheme.Colors.accent
                            : TeleportTheme.Colors.border,
                        lineWidth: isSelected && isAvailable ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}
