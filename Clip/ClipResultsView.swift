import SwiftUI
import StoreKit

// MARK: - Clip Results View

struct ClipResultsView: View {
    @Environment(ClipCoordinator.self) private var coordinator
    @Environment(\.displayStoreKitMessage) private var displayStoreKitMessage
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var appeared = false
    @State private var showOverlay = false

    private var matches: [CityMatch] {
        // Limit to 3 matches in the clip
        Array((coordinator.generatedResponse?.matches ?? []).prefix(3))
    }

    var body: some View {
        ZStack {
            // Main content
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

                        Text("Your Top Cities")
                            .font(TeleportTheme.Typography.title(24))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        Text("Here are \(matches.count) cities that match your lifestyle!")
                            .font(TeleportTheme.Typography.body(15))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }
                    .padding(.top, TeleportTheme.Spacing.xl)

                    // Match cards (limited to 3)
                    VStack(spacing: TeleportTheme.Spacing.md) {
                        ForEach(Array(matches.enumerated()), id: \.element.cityId) { index, match in
                            ClipResultCard(match: match, rank: index + 1)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 30)
                                .animation(
                                    .spring(response: 0.5).delay(Double(index) * 0.15),
                                    value: appeared
                                )
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)

                    // Teaser for more
                    VStack(spacing: TeleportTheme.Spacing.sm) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 28))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)

                        Text("Want more cities & detailed insights?")
                            .font(TeleportTheme.Typography.body(14))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }
                    .padding(.top, TeleportTheme.Spacing.sm)
                }
                .padding(.bottom, 120)
            }
            .background(TeleportTheme.Colors.background)

            // Bottom CTA
            VStack {
                Spacer()

                VStack(spacing: TeleportTheme.Spacing.sm) {
                    TeleportButton(title: "Get the Full App", icon: "arrow.down.app") {
                        analytics.trackButtonTap("download_full_app", screen: "clip_results")
                        analytics.track("clip_download_tapped", screen: "clip_results")
                        showOverlay = true
                    }

                    Button("Start Over") {
                        analytics.trackButtonTap("start_over", screen: "clip_results")
                        withAnimation {
                            coordinator.generatedResponse = nil
                            coordinator.preferences = .defaults
                            coordinator.currentScreen = .preferences
                        }
                    }
                    .font(TeleportTheme.Typography.body(14))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
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
        .appStoreOverlay(isPresented: $showOverlay) {
            SKOverlay.AppClipConfiguration(position: .bottom)
        }
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("clip_results")
            appeared = true
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("clip_results", durationMs: ms, exitType: "back")
        }
    }
}

// MARK: - Clip Result Card

private struct ClipResultCard: View {
    let match: CityMatch
    let rank: Int

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    // Rank badge
                    Text("#\(rank)")
                        .font(TeleportTheme.Typography.sectionHeader(13))
                        .foregroundStyle(TeleportTheme.Colors.background)
                        .frame(width: 32, height: 32)
                        .background(TeleportTheme.Colors.accent)
                        .clipShape(Circle())

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
                    .frame(width: 48, height: 48)
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
                    VStack(spacing: 2) {
                        Text("\(match.matchPercent)%")
                            .font(TeleportTheme.Typography.title(22))
                            .foregroundStyle(TeleportTheme.Colors.accent)

                        Text("match")
                            .font(TeleportTheme.Typography.caption(10))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    }
                }

                // AI Insight
                if let insight = match.aiInsight, !insight.isEmpty {
                    Text(insight)
                        .font(TeleportTheme.Typography.body(13))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .lineLimit(2)
                        .padding(.top, TeleportTheme.Spacing.xs)
                }
            }
        }
    }
}
