import SwiftUI

// MARK: - Vibe Selection View

/// A multi-select vibe picker grouped by category.
/// Used in onboarding, new exploration flow, App Clip, and profile editing.
struct VibeSelectionView: View {
    @Binding var selectedVibeIds: Set<String>
    let onContinue: () -> Void

    @State private var allVibeTags: [VibeTag] = []
    @State private var isLoading = true
    @State private var appeared = false
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared
    private let explorationService = ExplorationService()

    /// Minimum number of vibes the user must select before continuing.
    private let minimumSelection = 3

    var body: some View {
        ZStack {
            TeleportTheme.Colors.backgroundElevated.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(TeleportTheme.Colors.accent)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xl) {
                        // Header
                        VStack(spacing: TeleportTheme.Spacing.sm) {
                            Text("What vibes are you\nlooking for?")
                                .font(TeleportTheme.Typography.title(26))
                                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Pick at least \(minimumSelection) that describe your ideal city")
                                .font(TeleportTheme.Typography.body(15))
                                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, TeleportTheme.Spacing.xl)

                        // Selection count indicator
                        selectionIndicator

                        // Category groups
                        ForEach(Array(groupedTags.enumerated()), id: \.element.category) { index, group in
                            categorySection(group, index: index)
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                    .padding(.bottom, 100) // Space for button
                }
            }
        }
        .overlay(alignment: .bottom) {
            if !isLoading {
                TeleportButton(title: "Continue", icon: "arrow.right") {
                    analytics.trackButtonTap("continue", screen: "vibe_selection")
                    analytics.track("vibes_selected", screen: "vibe_selection", properties: [
                        "count": String(selectedVibeIds.count),
                        "vibe_ids": selectedVibeIds.joined(separator: ",")
                    ])
                    onContinue()
                }
                .disabled(selectedVibeIds.count < minimumSelection)
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.bottom, TeleportTheme.Spacing.lg)
                .background(
                    LinearGradient(
                        colors: [TeleportTheme.Colors.backgroundElevated.opacity(0), TeleportTheme.Colors.backgroundElevated],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadVibeTags()
        }
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("vibe_selection")
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("vibe_selection", durationMs: ms, exitType: "advanced")
        }
    }

    // MARK: - Selection Indicator

    private var selectionIndicator: some View {
        HStack(spacing: TeleportTheme.Spacing.sm) {
            Image(systemName: selectedVibeIds.count >= minimumSelection ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(
                    selectedVibeIds.count >= minimumSelection
                        ? TeleportTheme.Colors.accent
                        : TeleportTheme.Colors.textTertiary
                )

            Text("\(selectedVibeIds.count) selected")
                .font(TeleportTheme.Typography.cardTitle(15))
                .foregroundStyle(
                    selectedVibeIds.count >= minimumSelection
                        ? TeleportTheme.Colors.accent
                        : TeleportTheme.Colors.textSecondary
                )

            if selectedVibeIds.count < minimumSelection {
                Text("(\(minimumSelection - selectedVibeIds.count) more needed)")
                    .font(TeleportTheme.Typography.caption(13))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.spring(response: 0.3), value: selectedVibeIds.count)
    }

    // MARK: - Category Section

    private func categorySection(_ group: VibeGroup, index: Int) -> some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: group.category)

            FlowLayout(spacing: TeleportTheme.Spacing.sm) {
                ForEach(group.tags) { tag in
                    let isSelected = selectedVibeIds.contains(tag.id)
                    TrendingChip(
                        title: "\(tag.emoji ?? "") \(tag.name)",
                        isSelected: isSelected
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if isSelected {
                                selectedVibeIds.remove(tag.id)
                            } else {
                                selectedVibeIds.insert(tag.id)
                            }
                        }
                        analytics.track("vibe_toggled", screen: "vibe_selection", properties: [
                            "vibe_id": tag.id,
                            "vibe_name": tag.name,
                            "action": isSelected ? "removed" : "added"
                        ])
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8)
                .delay(Double(index) * 0.1),
            value: appeared
        )
    }

    // MARK: - Data

    /// Groups vibe tags by category in display order.
    private var groupedTags: [VibeGroup] {
        let order: [String] = VibeCategory.allCases.map(\.rawValue)
        let grouped = Dictionary(grouping: allVibeTags) { $0.category ?? "other" }
        return order.compactMap { category in
            guard let tags = grouped[category], !tags.isEmpty else { return nil }
            let displayName = VibeCategory(rawValue: category)?.displayName ?? category.capitalized
            return VibeGroup(category: displayName, tags: tags)
        }
    }

    private func loadVibeTags() async {
        do {
            allVibeTags = try await explorationService.fetchVibeTags()
        } catch {
            print("Failed to load vibe tags: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Vibe Group

private struct VibeGroup: Identifiable {
    let category: String
    let tags: [VibeTag]
    var id: String { category }
}

// MARK: - Flow Layout (wrapping chips)

/// A layout that arranges its children in horizontal rows,
/// wrapping to the next row when a child would exceed the available width.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(in maxWidth: CGFloat, subviews: Subviews) -> LayoutResult {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return LayoutResult(
            positions: positions,
            size: CGSize(width: maxX, height: currentY + rowHeight)
        )
    }

    private struct LayoutResult {
        let positions: [CGPoint]
        let size: CGSize
    }
}

// MARK: - Preview

#Preview("Vibe Selection") {
    NavigationStack {
        VibeSelectionView(
            selectedVibeIds: .constant(Set<String>()),
            onContinue: {}
        )
    }
    .preferredColorScheme(.dark)
}
