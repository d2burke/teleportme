import SwiftUI

// MARK: - Primary CTA Button (Lime pill)

struct TeleportButton: View {
    let title: String
    var icon: String? = nil
    var style: Style = .primary
    var isLoading: Bool = false
    let action: () -> Void

    enum Style {
        case primary    // Lime background, dark text
        case secondary  // Dark background, light border
        case ghost      // No background, accent text
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: TeleportTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(textColor)
                } else {
                    Text(title)
                        .font(TeleportTheme.Typography.cardTitle(17))
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay {
                if style == .secondary {
                    Capsule()
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: TeleportTheme.Colors.accent
        case .secondary: TeleportTheme.Colors.surface
        case .ghost: .clear
        }
    }

    private var textColor: Color {
        switch style {
        case .primary: TeleportTheme.Colors.background
        case .secondary: TeleportTheme.Colors.textPrimary
        case .ghost: TeleportTheme.Colors.accent
        }
    }
}

// MARK: - Card Container

struct CardView<Content: View>: View {
    var padding: CGFloat = TeleportTheme.Spacing.md
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(TeleportTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.card))
    }
}

// MARK: - Score Bar

struct ScoreBar: View {
    let label: String
    let score: Double
    let maxScore: Double
    var color: Color = TeleportTheme.Colors.accent
    var showValue: Bool = true
    var height: CGFloat = 6

    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
            if showValue {
                HStack {
                    Text(label)
                        .font(TeleportTheme.Typography.caption())
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    Spacer()
                    Text(String(format: "%.1f", score))
                        .font(TeleportTheme.Typography.caption())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(TeleportTheme.Colors.border)
                        .frame(height: height)

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(color)
                        .frame(width: geo.size.width * animatedProgress, height: height)
                }
            }
            .frame(height: height)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = min(CGFloat(score / maxScore), 1.0)
            }
        }
    }
}

// MARK: - Comparison Bar (side-by-side, from ComparisonView design)

struct ComparisonBar: View {
    let cityName: String
    let score: Double
    let maxScore: Double
    var color: Color = TeleportTheme.Colors.accent

    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        HStack(spacing: TeleportTheme.Spacing.sm) {
            Text(cityName)
                .font(TeleportTheme.Typography.caption(13))
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                .frame(width: 80, alignment: .leading)
                .lineLimit(1)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(TeleportTheme.Colors.border)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * animatedProgress, height: 6)
                }
            }
            .frame(height: 6)

            Text(String(format: "%.1f", score))
                .font(TeleportTheme.Typography.caption(13))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                .frame(width: 30, alignment: .trailing)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = min(CGFloat(score / maxScore), 1.0)
            }
        }
    }
}

// MARK: - Metric Card (from City Baseline screen)

struct MetricCard: View {
    let icon: String
    let category: String
    let score: Double
    let label: String
    var color: Color = TeleportTheme.Colors.accent

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(TeleportTheme.Colors.surfaceElevated)
                        .clipShape(Circle())

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(category.uppercased())
                            .font(TeleportTheme.Typography.sectionHeader(10))
                            .foregroundStyle(color)
                        Text(String(format: "%.1f", score))
                            .font(TeleportTheme.Typography.scoreValue(28))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    }
                }

                Text(label)
                    .font(TeleportTheme.Typography.caption(13))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)

                ScoreBar(
                    label: "",
                    score: score,
                    maxScore: 10,
                    color: color,
                    showValue: false,
                    height: 4
                )

                Text("/ 10")
                    .font(TeleportTheme.Typography.caption(11))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Trending Chip

struct TrendingChip: View {
    let title: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TeleportTheme.Typography.caption(14))
                .foregroundStyle(
                    isSelected
                        ? TeleportTheme.Colors.background
                        : TeleportTheme.Colors.textPrimary
                )
                .padding(.horizontal, TeleportTheme.Spacing.md)
                .padding(.vertical, TeleportTheme.Spacing.sm)
                .background(
                    isSelected
                        ? TeleportTheme.Colors.accent
                        : TeleportTheme.Colors.surface
                )
                .clipShape(Capsule())
                .overlay {
                    if !isSelected {
                        Capsule()
                            .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var color: Color = TeleportTheme.Colors.accent

    var body: some View {
        HStack(spacing: TeleportTheme.Spacing.sm) {
            Rectangle()
                .fill(color)
                .frame(width: 24, height: 2)

            Text(title.uppercased())
                .font(TeleportTheme.Typography.sectionHeader())
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                .tracking(1.5)

            Spacer()
        }
    }
}

// MARK: - City Hero Image

struct CityHeroImage: View {
    let imageURL: String?
    let cityName: String
    let subtitle: String
    var height: CGFloat = 300
    var matchPercent: Int? = nil
    var rank: Int? = nil
    var badge: String? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Image
                AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: height)
                    case .failure:
                        Rectangle().fill(TeleportTheme.Colors.surface)
                            .frame(width: geo.size.width, height: height)
                    default:
                        Rectangle()
                            .fill(TeleportTheme.Colors.surface)
                            .frame(width: geo.size.width, height: height)
                            .overlay {
                                ProgressView()
                                    .tint(TeleportTheme.Colors.accent)
                            }
                    }
                }
                .frame(width: geo.size.width, height: height)
                .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, TeleportTheme.Colors.background.opacity(0.9)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Text overlay
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    if let rank {
                        Text("#\(rank) TOP MATCH")
                            .font(TeleportTheme.Typography.sectionHeader(11))
                            .foregroundStyle(TeleportTheme.Colors.accent)
                    }

                    Text(cityName)
                        .font(TeleportTheme.Typography.heroTitle(36))
                        .foregroundStyle(.white)

                    HStack(spacing: TeleportTheme.Spacing.xs) {
                        Image(systemName: "globe")
                            .font(.caption)
                        Text(subtitle)
                            .font(TeleportTheme.Typography.body(14))
                    }
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
                .padding(TeleportTheme.Spacing.lg)

                // Match badge (top right)
                if let matchPercent {
                    VStack(spacing: 0) {
                        Text("\(matchPercent)%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("MATCH")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(TeleportTheme.Colors.background)
                    .frame(width: 64, height: 64)
                    .background(TeleportTheme.Colors.accent)
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(TeleportTheme.Spacing.md)
                }

                // Badge (top left)
                if let badge {
                    Text(badge)
                        .font(TeleportTheme.Typography.sectionHeader(11))
                        .foregroundStyle(TeleportTheme.Colors.background)
                        .padding(.horizontal, TeleportTheme.Spacing.sm)
                        .padding(.vertical, TeleportTheme.Spacing.xs)
                        .background(TeleportTheme.Colors.accent)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(TeleportTheme.Spacing.md)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.large))
        }
        .frame(height: height)
    }
}

// MARK: - Preference Slider Card

struct PreferenceSliderCard: View {
    let icon: String
    let title: String
    let lowLabel: String
    let highLabel: String
    @Binding var value: Double

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                        .frame(width: 40, height: 40)
                        .background(TeleportTheme.Colors.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                    Text(title)
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                }

                Slider(value: $value, in: 0...10, step: 0.5)
                    .tint(TeleportTheme.Colors.accent)

                HStack {
                    Text(lowLabel.uppercased())
                        .font(TeleportTheme.Typography.sectionHeader(10))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                    Spacer()
                    Text(highLabel.uppercased())
                        .font(TeleportTheme.Typography.sectionHeader(10))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Component Previews

#Preview("TeleportButton") {
    VStack(spacing: 16) {
        TeleportButton(title: "Primary Action", icon: "arrow.right") {}
        TeleportButton(title: "Secondary", style: .secondary) {}
        TeleportButton(title: "Ghost", style: .ghost) {}
        TeleportButton(title: "Loading", isLoading: true) {}
    }
    .padding()
    .background(TeleportTheme.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("ScoreBar") {
    VStack(spacing: 16) {
        ScoreBar(label: "Cost of Living", score: 7.5, maxScore: 10, color: TeleportTheme.Colors.scoreCost)
        ScoreBar(label: "Economy", score: 4.0, maxScore: 10, color: TeleportTheme.Colors.accent)
    }
    .padding()
    .background(TeleportTheme.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("MetricCard") {
    MetricCard(
        icon: "banknote",
        category: "Cost of Living",
        score: 7.5,
        label: "Affordable",
        color: TeleportTheme.Colors.scoreCost
    )
    .frame(width: 180)
    .preferredColorScheme(.dark)
}

#Preview("CityHeroImage") {
    CityHeroImage(
        imageURL: "https://images.unsplash.com/photo-1560969184-10fe8719e047?auto=format&fit=crop&w=800&q=80",
        cityName: "Berlin",
        subtitle: "Germany",
        matchPercent: 87,
        rank: 1
    )
    .padding()
    .background(TeleportTheme.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("PreferenceSliderCard") {
    PreferenceSliderCard(
        icon: "banknote",
        title: "Cost of Living",
        lowLabel: "Lower",
        highLabel: "Higher",
        value: .constant(7.0)
    )
    .padding()
    .background(TeleportTheme.Colors.background)
    .preferredColorScheme(.dark)
}

