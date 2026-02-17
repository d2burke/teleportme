import SwiftUI

// MARK: - Exploration Results Step

struct ExplorationResultsStepView: View {
    let response: GenerateReportResponse?
    let explorationTitle: String
    let onDone: () -> Void

    var body: some View {
        if let response {
            ReportDetailView(
                viewModel: ResultsViewModel(
                    from: response,
                    title: explorationTitle,
                    source: .newExploration
                ),
                isPostGeneration: true,
                onDone: onDone
            )
        } else {
            VStack(spacing: TeleportTheme.Spacing.lg) {
                ProgressView()
                    .tint(TeleportTheme.Colors.accent)
                Text("Loading results...")
                    .font(TeleportTheme.Typography.body())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(TeleportTheme.Colors.background)
        }
    }
}
