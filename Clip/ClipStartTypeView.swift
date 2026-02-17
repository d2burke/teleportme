import SwiftUI

// MARK: - Clip Start Type View

/// Simplified start type selection for the App Clip.
/// Offers "A City I Love" and "Vibes" paths (no "My Own Words" in clip).
struct ClipStartTypeView: View {
    @Environment(ClipCoordinator.self) private var coordinator
    @State private var appeared = false

    private let options: [(StartType, String, String, String)] = [
        (.cityILove, "A City I Love", "Start with a city you love and find similar ones", "building.2"),
        (.vibes, "A Place That Feels Like Me", "Choose vibes and values to find your ideal city", "hand.thumbsup"),
    ]

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            Spacer()

            // Logo
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 48))
                .foregroundStyle(TeleportTheme.Colors.accent)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5).delay(0), value: appeared)

            Text("How do you want\nto explore?")
                .font(TeleportTheme.Typography.title(24))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5).delay(0.1), value: appeared)

            VStack(spacing: TeleportTheme.Spacing.md) {
                ForEach(Array(options.enumerated()), id: \.0) { index, option in
                    ClipMethodCard(
                        type: option.0,
                        title: option.1,
                        description: option.2,
                        icon: option.3,
                        isSelected: coordinator.selectedStartType == option.0
                    ) {
                        coordinator.selectedStartType = option.0
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1 + 0.2),
                        value: appeared
                    )
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)

            Spacer()

            TeleportButton(title: "Continue", icon: "arrow.right") {
                coordinator.advanceFromStartType()
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .padding(.bottom, TeleportTheme.Spacing.lg)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5).delay(0.5), value: appeared)
        }
        .background(TeleportTheme.Colors.background)
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Clip Method Card

private struct ClipMethodCard: View {
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
                    .foregroundStyle(
                        isSelected ? TeleportTheme.Colors.accent : TeleportTheme.Colors.textSecondary
                    )
                    .frame(width: 48, height: 48)
                    .background(TeleportTheme.Colors.surfaceElevated)
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

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        isSelected ? TeleportTheme.Colors.accent : TeleportTheme.Colors.border
                    )
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
}
