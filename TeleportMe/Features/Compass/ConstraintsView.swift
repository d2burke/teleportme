import SwiftUI

// MARK: - Constraints View

/// Quick accordion-style constraint selection. Three sections, auto-advance on selection.
/// Nothing is mandatory — users can select 1, 2, or all 3, or skip entirely.
struct ConstraintsView: View {
    @Binding var constraints: TripConstraints
    let onContinue: () -> Void
    var onBack: (() -> Void)?

    @State private var activeSection: Int = 0

    private var someDone: Bool { constraints.hasAny }
    private var allDone: Bool { constraints.count == 3 }

    var body: some View {
        ZStack {
            TeleportTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    if let onBack {
                        Button(action: onBack) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Vibes")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        }
                        .padding(.bottom, 12)
                    }

                    Text("Constraints")
                        .font(TeleportTheme.Typography.title(24))
                        .foregroundStyle(.white)

                    Text(allDone ? "All set. Three taps, no forms." : "The practical stuff. Quick taps — not a form.")
                        .font(.system(size: 13))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.top, TeleportTheme.Spacing.md)

                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        let isFilled = constraintDone(at: i)
                        let isCurrent = i == activeSection && !isFilled
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                isFilled ? Color.white :
                                isCurrent ? Color.white.opacity(0.25) :
                                Color.white.opacity(0.06)
                            )
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.top, TeleportTheme.Spacing.md)
                .padding(.bottom, TeleportTheme.Spacing.lg)

                // Constraint sections
                ScrollView {
                    VStack(spacing: 14) {
                        ConstraintSection(
                            title: "How far will you go?",
                            subtitle: "From your corner of the world",
                            isActive: activeSection == 0,
                            isDone: constraints.travelDistance != nil,
                            selectedLabel: constraints.travelDistance?.label
                        ) {
                            ForEach(TripConstraints.TravelDistance.allCases) { option in
                                ConstraintOptionCard(
                                    emoji: option.emoji,
                                    label: option.label,
                                    description: option.description,
                                    isSelected: constraints.travelDistance == option
                                ) {
                                    selectTravel(option)
                                }
                            }
                        }

                        ConstraintSection(
                            title: "Comfort level?",
                            subtitle: "No wrong answer",
                            isActive: activeSection == 1,
                            isDone: constraints.safetyComfort != nil,
                            selectedLabel: constraints.safetyComfort?.label
                        ) {
                            ForEach(TripConstraints.SafetyComfort.allCases) { option in
                                ConstraintOptionCard(
                                    emoji: option.emoji,
                                    label: option.label,
                                    description: option.description,
                                    isSelected: constraints.safetyComfort == option
                                ) {
                                    selectSafety(option)
                                }
                            }
                        }

                        ConstraintSection(
                            title: "What's the budget vibe?",
                            subtitle: "For the whole trip",
                            isActive: activeSection == 2,
                            isDone: constraints.budgetVibe != nil,
                            selectedLabel: constraints.budgetVibe?.label
                        ) {
                            ForEach(TripConstraints.BudgetVibe.allCases) { option in
                                ConstraintOptionCard(
                                    emoji: option.emoji,
                                    label: option.label,
                                    description: option.description,
                                    isSelected: constraints.budgetVibe == option
                                ) {
                                    selectBudget(option)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }

                // Summary strip (when all done)
                if allDone {
                    HStack(spacing: 6) {
                        if let travel = constraints.travelDistance {
                            constraintPill(emoji: travel.emoji, label: travel.label)
                        }
                        if let safety = constraints.safetyComfort {
                            constraintPill(emoji: safety.emoji, label: safety.label)
                        }
                        if let budget = constraints.budgetVibe {
                            constraintPill(emoji: budget.emoji, label: budget.label)
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                    .padding(.top, TeleportTheme.Spacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // CTA Button
                Button(action: onContinue) {
                    Text(ctaLabel)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Group {
                                if allDone {
                                    LinearGradient(
                                        colors: [Color(hex: "E6922E"), Color(hex: "E6922E").opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color.white.opacity(someDone ? 0.1 : 0.04)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.large))
                        .shadow(
                            color: allDone ? Color(hex: "E6922E").opacity(0.2) : .clear,
                            radius: 10,
                            y: 6
                        )
                }
                .disabled(!someDone)
                .opacity(someDone ? 1 : 0.3)
                .padding(.horizontal, TeleportTheme.Spacing.xl)
                .padding(.top, TeleportTheme.Spacing.md)
                .padding(.bottom, TeleportTheme.Spacing.xxl)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: activeSection)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: allDone)
    }

    // MARK: - Helpers

    private var ctaLabel: String {
        if allDone { return "Show me where to go \u{2726}" }
        if someDone { return "Skip the rest \u{2192}" }
        return "Choose at least one"
    }

    private func constraintDone(at index: Int) -> Bool {
        switch index {
        case 0: return constraints.travelDistance != nil
        case 1: return constraints.safetyComfort != nil
        case 2: return constraints.budgetVibe != nil
        default: return false
        }
    }

    private func selectTravel(_ option: TripConstraints.TravelDistance) {
        constraints.travelDistance = option
        advanceAfterDelay()
    }

    private func selectSafety(_ option: TripConstraints.SafetyComfort) {
        constraints.safetyComfort = option
        advanceAfterDelay()
    }

    private func selectBudget(_ option: TripConstraints.BudgetVibe) {
        constraints.budgetVibe = option
    }

    private func advanceAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if activeSection < 2 {
                activeSection += 1
            }
        }
    }

    @ViewBuilder
    private func constraintPill(emoji: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 9))
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.4))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Constraint Section

/// An accordion section that collapses when answered and expands when active.
private struct ConstraintSection<Content: View>: View {
    let title: String
    let subtitle: String
    let isActive: Bool
    let isDone: Bool
    let selectedLabel: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    if isActive {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    } else if isDone, let label = selectedLabel {
                        Text(label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.4))
                    }
                }

                Spacer()

                if isDone && !isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: "4ECB71"))
                        .padding(5)
                        .background(
                            Circle()
                                .fill(Color(hex: "4ECB71").opacity(0.12))
                        )
                }
            }

            // Options (only when active)
            if isActive {
                VStack(spacing: 8) {
                    content()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .opacity(isActive ? 1 : isDone ? 0.6 : 0.25)
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}

// MARK: - Constraint Option Card

/// A single option within a constraint section.
private struct ConstraintOptionCard: View {
    let emoji: String
    let label: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 22))

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(.white)

                    Text(description)
                        .font(.system(size: 11))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: "4ECB71"))
                        .padding(4)
                        .background(
                            Circle()
                                .fill(Color(hex: "4ECB71").opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: TeleportTheme.Radius.card)
                    .fill(isSelected ? Color.white.opacity(0.06) : Color.white.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: TeleportTheme.Radius.card)
                            .stroke(
                                isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.04),
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isSelected)
    }
}

#Preview {
    ConstraintsView(
        constraints: .constant(TripConstraints()),
        onContinue: {},
        onBack: {}
    )
}
