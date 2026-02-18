import SwiftUI

// MARK: - Start Type Card (shared component)

/// Reusable card for displaying a start-type option (city I love, compass, my own words).
/// Used by `ExplorationMethodStepView` in both onboarding and new-exploration flows.
struct StartTypeCard: View {
    let type: StartType
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(iconColor)
                    .frame(width: 48, height: 48)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))

                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text(title)
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Text(description)
                        .font(TeleportTheme.Typography.body(13))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(TeleportTheme.Spacing.md)
            .background(TeleportTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.card))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.card)
                        .strokeBorder(TeleportTheme.Colors.accent, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch type {
        case .cityILove: TeleportTheme.Colors.textSecondary
        case .vibes: TeleportTheme.Colors.accent
        case .myWords: TeleportTheme.Colors.accent
        }
    }

    private var iconBackground: Color {
        switch type {
        case .cityILove: TeleportTheme.Colors.surfaceElevated
        case .vibes: TeleportTheme.Colors.surfaceElevated
        case .myWords: TeleportTheme.Colors.accent.opacity(0.2)
        }
    }
}

// MARK: - Preview

#Preview("Start Type Card") {
    StartTypeCard(
        type: .cityILove,
        title: "A city I love",
        description: "Start with a city you love and why",
        icon: "building.2",
        isSelected: true
    ) {}
    .padding()
    .background(TeleportTheme.Colors.background)
    .preferredColorScheme(.dark)
}
