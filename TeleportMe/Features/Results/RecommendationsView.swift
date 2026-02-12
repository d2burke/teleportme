import SwiftUI

struct RecommendationsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var appeared = false
    @State private var selectedMatchIndex = 0
    @State private var showShareSheet = false

    private var matches: [CityMatch] {
        coordinator.reportService.currentReport?.matches ?? []
    }

    private var currentCity: CurrentCityInfo? {
        coordinator.reportService.currentReport?.currentCity
    }

    private var shareText: String {
        var text = "Check out my TeleportMe city matches!\n\n"
        for match in matches {
            text += "#\(match.rank) \(match.cityName) - \(match.matchPercent)% match\n"
        }
        return text
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.lg) {
                // Title
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        HStack(spacing: 0) {
                            Text("Top City\n")
                                .font(TeleportTheme.Typography.title(32))
                                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                            +
                            Text("Recommendations")
                                .font(TeleportTheme.Typography.title(32))
                                .foregroundStyle(TeleportTheme.Colors.accent)
                        }

                        Text("We've found \(matches.count) compatible cities based on your lifestyle profile.")
                            .font(TeleportTheme.Typography.body(15))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)

                    // Top match hero card (horizontal scroll for multiple)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: TeleportTheme.Spacing.md) {
                            ForEach(Array(matches.enumerated()), id: \.1.id) { index, match in
                                CityHeroImage(
                                    imageURL: match.cityImageUrl,
                                    cityName: match.cityName,
                                    subtitle: match.cityCountry,
                                    height: 320,
                                    matchPercent: match.matchPercent,
                                    rank: match.rank
                                )
                                .frame(width: UIScreen.main.bounds.width - 80)
                                .onTapGesture {
                                    selectedMatchIndex = index
                                }
                            }
                        }
                        .padding(.horizontal, TeleportTheme.Spacing.lg)
                    }

                    // Comparison section
                    if let topMatch = matches.first {
                        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                            HStack {
                                Text("The Comparison")
                                    .font(TeleportTheme.Typography.title(22))
                                    .foregroundStyle(TeleportTheme.Colors.textPrimary)

                                Spacer()

                                if let currentName = currentCity?.name {
                                    Text("V. \(currentName.uppercased())")
                                        .font(TeleportTheme.Typography.sectionHeader(11))
                                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                }
                            }

                            // Comparison cards
                            if let comparison = topMatch.comparison {
                                ForEach(Array(comparison.keys.sorted()), id: \.self) { category in
                                    if let metric = comparison[category] {
                                        ComparisonCard(
                                            category: category,
                                            matchScore: metric.matchScore,
                                            currentScore: metric.currentScore,
                                            delta: metric.delta,
                                            matchCityName: topMatch.cityName,
                                            currentCityName: currentCity?.name ?? "Current"
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, TeleportTheme.Spacing.lg)

                        // AI Insight
                        if let insight = topMatch.aiInsight {
                            CardView {
                                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                                    HStack(spacing: TeleportTheme.Spacing.sm) {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(TeleportTheme.Colors.accent)
                                        Text("Expert Insights")
                                            .font(TeleportTheme.Typography.cardTitle())
                                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                                    }

                                    Text(insight)
                                        .font(TeleportTheme.Typography.body(14))
                                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                                        .lineSpacing(4)
                                }
                            }
                            .padding(.horizontal, TeleportTheme.Spacing.lg)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("RECOMMENDATIONS")
                    .font(TeleportTheme.Typography.sectionHeader(12))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .tracking(1.5)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
            }
        }
        .overlay(alignment: .bottom) {
            // Bottom CTA bar
            HStack(spacing: TeleportTheme.Spacing.md) {
                TeleportButton(title: "Share", icon: "square.and.arrow.up", style: .secondary) {
                    showShareSheet = true
                }

                TeleportButton(title: "Let's Go") {
                    coordinator.completeOnboarding()
                }
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
        .sheet(isPresented: $showShareSheet) {
            ActivityView(text: shareText)
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

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(category)
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
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
