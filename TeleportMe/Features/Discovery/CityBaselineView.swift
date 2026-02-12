import SwiftUI

struct CityBaselineView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var appeared = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: TeleportTheme.Spacing.lg) {
                // Hero image
                if let city = coordinator.selectedCity {
                    CityHeroImage(
                        imageURL: city.city.imageUrl,
                        cityName: city.city.name,
                        subtitle: city.city.country,
                        height: 280,
                        badge: "CURRENT BASELINE"
                    )
                    .padding(.horizontal, TeleportTheme.Spacing.md)

                    // Section header
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                        SectionHeader(title: "Live Data Tracking")

                        Text("How you live today")
                            .font(TeleportTheme.Typography.title(28))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        Text("Your current lifestyle metrics mapped to a 10.0 scale. This is your personal benchmark for all future city recommendations.")
                            .font(TeleportTheme.Typography.body(15))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)

                    // Metric cards grid (2 columns)
                    let metrics = city.displayMetrics
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: TeleportTheme.Spacing.md),
                            GridItem(.flexible(), spacing: TeleportTheme.Spacing.md),
                        ],
                        spacing: TeleportTheme.Spacing.md
                    ) {
                        ForEach(Array(metrics.prefix(4).enumerated()), id: \.1.id) { index, metric in
                            MetricCard(
                                icon: metric.icon,
                                category: metric.category,
                                score: metric.score,
                                label: metric.label,
                                color: TeleportTheme.Colors.forCategory(metricCategoryKey(metric.category))
                            )
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

                    // Full-width mobility card (5th metric)
                    if let mobility = metrics.last {
                        CardView {
                            HStack(spacing: TeleportTheme.Spacing.md) {
                                Image(systemName: mobility.icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                                    .frame(width: 48, height: 48)
                                    .background(TeleportTheme.Colors.surfaceElevated)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                                    Text(mobility.category.uppercased())
                                        .font(TeleportTheme.Typography.sectionHeader(10))
                                        .foregroundStyle(TeleportTheme.Colors.scoreMobility)

                                    Text(mobility.label)
                                        .font(TeleportTheme.Typography.cardTitle())
                                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                                    ScoreBar(
                                        label: "",
                                        score: mobility.score,
                                        maxScore: 10,
                                        color: TeleportTheme.Colors.scoreMobility,
                                        showValue: false,
                                        height: 4
                                    )
                                }

                                Spacer()

                                Text(String(format: "%.1f", mobility.score))
                                    .font(TeleportTheme.Typography.scoreValue(28))
                                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                            }
                        }
                        .padding(.horizontal, TeleportTheme.Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.5).delay(0.4), value: appeared)
                    }
                } else {
                    // Loading state
                    VStack(spacing: TeleportTheme.Spacing.md) {
                        ProgressView()
                            .tint(TeleportTheme.Colors.accent)
                        Text("Loading city data...")
                            .font(TeleportTheme.Typography.body())
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 200)
                }

                // CTA — only enabled when city data has loaded
                TeleportButton(title: "Next: Target Factors", icon: "arrow.right") {
                    coordinator.advanceOnboarding(from: .cityBaseline)
                }
                .disabled(coordinator.selectedCity == nil)
                .opacity(coordinator.selectedCity != nil ? 1 : 0.4)
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.bottom, TeleportTheme.Spacing.xxl)
            }
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }

    /// Maps display-friendly category names back to score keys for coloring
    private func metricCategoryKey(_ displayName: String) -> String {
        switch displayName {
        case "Cost of Living": return "Cost of Living"
        case "Climate": return "Environmental Quality"
        case "Culture": return "Leisure & Culture"
        case "Jobs": return "Economy"
        case "Mobility": return "Commute"
        default: return displayName
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        CityBaselineView()
    }
}
