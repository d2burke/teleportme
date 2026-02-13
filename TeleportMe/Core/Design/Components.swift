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

    @State private var showInfo = false

    private var explainer: MetricExplainer? {
        MetricExplainer.forCategory(category)
    }

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

                // Expandable info
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

                ScoreBar(
                    label: "",
                    score: score,
                    maxScore: 10,
                    color: color,
                    showValue: false,
                    height: 4
                )

                HStack {
                    if explainer != nil {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showInfo.toggle()
                            }
                        } label: {
                            Image(systemName: showInfo ? "xmark.circle.fill" : "info.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(
                                    showInfo
                                        ? TeleportTheme.Colors.textSecondary
                                        : TeleportTheme.Colors.textTertiary
                                )
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Text("/ 10")
                        .font(TeleportTheme.Typography.caption(11))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }
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

// MARK: - Preference Metric Definitions

/// Single source of truth for preference slider configuration.
/// All preference views should use these definitions to stay consistent.
struct PreferenceMetric: Identifiable {
    let id: String
    let icon: String
    let title: String
    let lowLabel: String
    let highLabel: String
    let keyPath: WritableKeyPath<UserPreferences, Double>

    /// The standard preference metrics used throughout the app.
    static let all: [PreferenceMetric] = [
        PreferenceMetric(
            id: "cost",
            icon: "banknote",
            title: "Cost of Living",
            lowLabel: "Lower",
            highLabel: "Higher",
            keyPath: \.costPreference
        ),
        PreferenceMetric(
            id: "climate",
            icon: "thermometer.sun",
            title: "Climate",
            lowLabel: "Colder",
            highLabel: "Warmer",
            keyPath: \.climatePreference
        ),
        PreferenceMetric(
            id: "culture",
            icon: "theatermasks",
            title: "Culture & Lifestyle",
            lowLabel: "Chill",
            highLabel: "Vibrant",
            keyPath: \.culturePreference
        ),
        PreferenceMetric(
            id: "jobs",
            icon: "briefcase",
            title: "Job Market",
            lowLabel: "Niche",
            highLabel: "Growth",
            keyPath: \.jobMarketPreference
        ),
        PreferenceMetric(
            id: "safety",
            icon: "shield.checkered",
            title: "Safety",
            lowLabel: "Flexible",
            highLabel: "Safest",
            keyPath: \.safetyPreference
        ),
        PreferenceMetric(
            id: "commute",
            icon: "tram",
            title: "Commute & Transit",
            lowLabel: "Car OK",
            highLabel: "Transit",
            keyPath: \.commutePreference
        ),
        PreferenceMetric(
            id: "healthcare",
            icon: "heart.text.clipboard",
            title: "Healthcare",
            lowLabel: "Basic",
            highLabel: "Top-tier",
            keyPath: \.healthcarePreference
        ),
    ]
}

// MARK: - Preference Sliders List

/// A convenience view that renders all four preference sliders with staggered animations.
/// Use this instead of manually listing PreferenceSliderCards in each view.
struct PreferenceSlidersList: View {
    @Binding var preferences: UserPreferences
    var animated: Bool = true
    @State private var appeared = false

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.md) {
            ForEach(Array(PreferenceMetric.all.enumerated()), id: \.element.id) { index, metric in
                PreferenceSliderCard(
                    icon: metric.icon,
                    title: metric.title,
                    lowLabel: metric.lowLabel,
                    highLabel: metric.highLabel,
                    value: Binding(
                        get: { preferences[keyPath: metric.keyPath] },
                        set: { preferences[keyPath: metric.keyPath] = $0 }
                    )
                )
                .opacity(animated ? (appeared ? 1 : 0) : 1)
                .offset(y: animated ? (appeared ? 0 : 20) : 0)
                .animation(
                    animated ? .spring(response: 0.5).delay(Double(index) * 0.1) : nil,
                    value: appeared
                )
            }
        }
        .onAppear {
            if animated { appeared = true }
        }
    }
}

// MARK: - Preference Explainer Data

/// Describes what a preference metric means and what low/high values indicate.
struct PreferenceExplainer {
    let summary: String
    let lowExplainer: String
    let highExplainer: String

    /// Returns the explainer for a known preference metric, or nil for unknown ones.
    static func forMetric(_ title: String) -> PreferenceExplainer? {
        switch title {
        case "Cost of Living":
            return PreferenceExplainer(
                summary: "How important affordability is in your ideal city — housing, food, transport, and everyday expenses.",
                lowExplainer: "You're open to pricier cities if they deliver on other priorities.",
                highExplainer: "You want a city where your money goes further — lower rent, cheaper groceries, and affordable day-to-day living."
            )
        case "Climate":
            return PreferenceExplainer(
                summary: "Your temperature and weather preference — from cool, four-season climates to year-round warmth.",
                lowExplainer: "You prefer cooler temps, distinct seasons, or milder summers.",
                highExplainer: "You want warm or hot weather most of the year — sunshine and mild winters."
            )
        case "Culture & Lifestyle":
            return PreferenceExplainer(
                summary: "How much nightlife, arts, dining, and social energy you want in your city.",
                lowExplainer: "You prefer a quieter, more relaxed pace — fewer crowds, more nature.",
                highExplainer: "You want a buzzing city with world-class restaurants, museums, music, and events."
            )
        case "Job Market":
            return PreferenceExplainer(
                summary: "How strong the local economy and career opportunities are — startups, tech, remote-friendliness.",
                lowExplainer: "Career growth isn't your top priority — you may work remotely or are flexible.",
                highExplainer: "You want a city with a thriving job market, high salaries, and strong industry presence."
            )
        case "Safety":
            return PreferenceExplainer(
                summary: "How important personal safety and low crime rates are in choosing your city.",
                lowExplainer: "You're flexible on safety rankings — other factors matter more.",
                highExplainer: "Safety is a top priority — you want a city known for low crime and feeling secure."
            )
        case "Commute & Transit":
            return PreferenceExplainer(
                summary: "How much you value public transit, walkability, and short commute times.",
                lowExplainer: "You're fine with driving or don't mind longer commutes.",
                highExplainer: "You want excellent public transit, bike-friendly streets, and a walkable city."
            )
        case "Healthcare":
            return PreferenceExplainer(
                summary: "How important access to quality healthcare, hospitals, and medical services is.",
                lowExplainer: "Healthcare quality isn't a dealbreaker — you're healthy or have flexibility.",
                highExplainer: "You want top-tier hospitals, specialists, and accessible medical care."
            )
        default:
            return nil
        }
    }
}

// MARK: - Metric Explainer (for score cards throughout the app)

/// Describes what a city score category measures.
/// Used by MetricCard, ScoreCategoryRow, and ComparisonCard.
struct MetricExplainer {
    let summary: String

    /// Returns the explainer for a known score category (using Teleport API category names).
    /// Accepts both display names ("Climate", "Jobs") and API names ("Environmental Quality", "Economy").
    static func forCategory(_ category: String) -> MetricExplainer? {
        switch category {
        case "Cost of Living":
            return MetricExplainer(
                summary: "Covers housing costs, groceries, transport, and everyday spending power relative to income."
            )
        case "Environmental Quality", "Climate":
            return MetricExplainer(
                summary: "Air quality, green spaces, weather conditions, and overall environmental livability."
            )
        case "Leisure & Culture", "Culture":
            return MetricExplainer(
                summary: "Nightlife, restaurants, art, music, museums, and social activity options."
            )
        case "Economy", "Jobs":
            return MetricExplainer(
                summary: "Employment opportunities, salary levels, startup ecosystem, and career growth potential."
            )
        case "Safety":
            return MetricExplainer(
                summary: "Crime rates, personal safety, political stability, and general feeling of security."
            )
        case "Commute", "Mobility":
            return MetricExplainer(
                summary: "Public transit quality, walkability, bike infrastructure, and average commute times."
            )
        case "Healthcare":
            return MetricExplainer(
                summary: "Hospital quality, access to specialists, insurance systems, and overall medical care."
            )
        case "Housing":
            return MetricExplainer(
                summary: "Rental prices, home affordability, living space, and housing market conditions."
            )
        case "Taxation":
            return MetricExplainer(
                summary: "Income tax rates, sales tax, and overall tax burden for residents."
            )
        case "Internet Access":
            return MetricExplainer(
                summary: "Broadband speed, reliability, coverage, and access to coworking and tech infrastructure."
            )
        case "Tolerance":
            return MetricExplainer(
                summary: "Social openness, diversity, LGBTQ+ rights, and inclusivity of the local community."
            )
        case "Outdoors":
            return MetricExplainer(
                summary: "Parks, hiking, beaches, nature access, and outdoor recreation opportunities."
            )
        case "Education":
            return MetricExplainer(
                summary: "School quality, university access, research output, and lifelong learning options."
            )
        case "Travel Connectivity":
            return MetricExplainer(
                summary: "Airport access, international flight routes, train networks, and ease of getting around the region."
            )
        case "Startups":
            return MetricExplainer(
                summary: "Density of startups, accelerator programs, coworking spaces, and entrepreneurial energy."
            )
        case "Venture Capital":
            return MetricExplainer(
                summary: "Availability of funding, investor networks, and access to growth capital."
            )
        case "Business Freedom":
            return MetricExplainer(
                summary: "Ease of starting a business, regulatory environment, and economic freedom."
            )
        default:
            return nil
        }
    }
}

// MARK: - Preference Slider Card

struct PreferenceSliderCard: View {
    let icon: String
    let title: String
    let lowLabel: String
    let highLabel: String
    @Binding var value: Double

    @State private var showExplainer = false

    private var explainer: PreferenceExplainer? {
        PreferenceExplainer.forMetric(title)
    }

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

                    Spacer()

                    if explainer != nil {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showExplainer.toggle()
                            }
                        } label: {
                            Image(systemName: showExplainer ? "xmark.circle.fill" : "info.circle")
                                .font(.system(size: 18))
                                .foregroundStyle(
                                    showExplainer
                                        ? TeleportTheme.Colors.textSecondary
                                        : TeleportTheme.Colors.textTertiary
                                )
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Expandable explainer
                if showExplainer, let explainer {
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                        Text(explainer.summary)
                            .font(TeleportTheme.Typography.caption(13))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(alignment: .top, spacing: TeleportTheme.Spacing.md) {
                            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                                Text(lowLabel.uppercased())
                                    .font(TeleportTheme.Typography.sectionHeader(10))
                                    .foregroundStyle(TeleportTheme.Colors.accent)
                                Text(explainer.lowExplainer)
                                    .font(TeleportTheme.Typography.caption(12))
                                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                                Text(highLabel.uppercased())
                                    .font(TeleportTheme.Typography.sectionHeader(10))
                                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                                Text(explainer.highExplainer)
                                    .font(TeleportTheme.Typography.caption(12))
                                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(TeleportTheme.Spacing.sm)
                    .background(TeleportTheme.Colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                    ))
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

