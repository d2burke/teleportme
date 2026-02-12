import SwiftUI

struct StartTypeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var appeared = false

    private let options: [(StartType, String, String, String)] = [
        (.cityILove, "A city I love", "Start with a city you love and why. We'll show you similar ones", "building.2"),
        (.vibes, "A place that feels like me", "Tell us all the specific feels and values that are important to you", "hand.thumbsup"),
        (.myWords, "My own words", "Describe your ideal city in chat and we'll find matches for you", "bubble.left"),
    ]

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            Spacer()

            Text("All set! How would you\nlike to get started?")
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
                        isSelected: coordinator.selectedStartType == option.0
                    ) {
                        coordinator.selectedStartType = option.0
                        coordinator.preferences.startType = option.0

                        // For MVP, "city I love" path goes to city search
                        // Other paths can be wired up later
                        coordinator.advanceOnboarding(from: .startType)
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
        .background(TeleportTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Start Type Card

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

// MARK: - Previews

#Preview("Start Type Selection") {
    PreviewContainer {
        StartTypeView()
    }
}

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
