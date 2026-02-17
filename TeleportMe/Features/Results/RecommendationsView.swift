import SwiftUI

struct RecommendationsView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        if let currentReport = coordinator.reportService.currentReport {
            ReportDetailView(
                viewModel: ResultsViewModel(from: currentReport, source: .onboarding),
                isPostGeneration: true,
                onDone: {
                    coordinator.completeOnboarding()
                }
            )
        } else {
            ProgressView()
                .tint(TeleportTheme.Colors.accent)
        }
    }
}

// MARK: - Activity View (UIActivityViewController Wrapper)

struct ActivityView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Comparison Card

struct ComparisonCard: View {
    let category: String
    let matchScore: Double
    let currentScore: Double
    let delta: Double
    let matchCityName: String
    let currentCityName: String

    @State private var showInfo = false

    private var icon: String {
        switch category {
        case "Housing": return "house"
        case "Cost of Living": return "dollarsign.circle"
        case "Safety": return "shield"
        case "Commute": return "bus"
        case "Leisure & Culture": return "theatermasks"
        case "Internet Access": return "wifi"
        case "Healthcare": return "cross.case"
        case "Outdoors": return "leaf"
        default: return "chart.bar"
        }
    }

    private var color: Color {
        TeleportTheme.Colors.forCategory(category)
    }

    private var explainer: MetricExplainer? {
        MetricExplainer.forCategory(category)
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(category)
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Spacer()

                    if explainer != nil {
                        Button {
                            if !showInfo {
                                AnalyticsService.shared.track("comparison_info_tapped", screen: "recommendations", properties: [
                                    "category": category
                                ])
                            }
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showInfo.toggle()
                            }
                        } label: {
                            Image(systemName: showInfo ? "xmark.circle.fill" : "info.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(
                                    showInfo
                                        ? TeleportTheme.Colors.textSecondary
                                        : TeleportTheme.Colors.textTertiary
                                )
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if showInfo, let explainer {
                    Text(explainer.summary)
                        .font(TeleportTheme.Typography.caption(12))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(TeleportTheme.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(TeleportTheme.Colors.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                            removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                        ))
                }

                ComparisonBar(
                    cityName: matchCityName,
                    score: matchScore,
                    maxScore: 10,
                    color: color
                )

                ComparisonBar(
                    cityName: currentCityName,
                    score: currentScore,
                    maxScore: 10,
                    color: .gray
                )

                if delta != 0 {
                    HStack {
                        Spacer()
                        Text(delta > 0 ? "+\(String(format: "%.1f", delta))" : String(format: "%.1f", delta))
                            .font(TeleportTheme.Typography.caption(12))
                            .foregroundStyle(delta > 0 ? .green : .red)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Recommendations") {
    PreviewContainer(coordinator: PreviewHelpers.makeCoordinatorWithReport()) {
        RecommendationsView()
    }
}

#Preview("Comparison Card") {
    ComparisonCard(
        category: "Cost of Living",
        matchScore: 7.0,
        currentScore: 2.5,
        delta: 4.5,
        matchCityName: "Berlin",
        currentCityName: "San Francisco"
    )
    .padding()
    .background(TeleportTheme.Colors.background)
    .preferredColorScheme(.dark)
}
