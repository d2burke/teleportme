import SwiftUI

// MARK: - Exploration Results Step

struct ExplorationResultsStepView: View {
    let response: GenerateReportResponse?
    let explorationTitle: String
    let onDone: () -> Void

    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: TeleportTheme.Spacing.xl) {
                // Success header
                VStack(spacing: TeleportTheme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.5)
                        .animation(.spring(response: 0.5), value: appeared)

                    Text(explorationTitle)
                        .font(TeleportTheme.Typography.title(24))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    if let matches = response?.matches {
                        Text("We found \(matches.count) cities for you!")
                            .font(TeleportTheme.Typography.body(15))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }
                }
                .padding(.top, TeleportTheme.Spacing.xl)

                // Match cards
                if let matches = response?.matches {
                    VStack(spacing: TeleportTheme.Spacing.md) {
                        ForEach(Array(matches.enumerated()), id: \.element.cityId) { index, match in
                            ExplorationResultCard(match: match)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 30)
                                .animation(
                                    .spring(response: 0.5).delay(Double(index) * 0.1),
                                    value: appeared
                                )
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
            }
            .padding(.bottom, 100)
        }
        .background(TeleportTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .bottom) {
            TeleportButton(title: "Done", icon: "checkmark") {
                onDone()
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
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Result Card

private struct ExplorationResultCard: View {
    let match: CityMatch

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    // City image
                    AsyncImage(url: URL(string: match.cityImageUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(TeleportTheme.Colors.surfaceElevated)
                                .overlay {
                                    Image(systemName: "building.2")
                                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                }
                        }
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                    // City info
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        Text(match.cityName)
                            .font(TeleportTheme.Typography.cardTitle(18))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        Text(match.cityCountry)
                            .font(TeleportTheme.Typography.body(14))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }

                    Spacer()

                    // Match percent
                    Text("\(match.matchPercent)%")
                        .font(TeleportTheme.Typography.title(22))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                }

                // AI Insight
                if let insight = match.aiInsight, !insight.isEmpty {
                    Text(insight)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .lineLimit(3)
                }
            }
        }
    }
}
