import SwiftUI

// MARK: - Clip Generating View

struct ClipGeneratingView: View {
    @Environment(ClipCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var progress: CGFloat = 0
    @State private var currentMessageIndex = 0

    private let statusMessages = [
        "Reading your signal weights...",
        "Scanning cities worldwide...",
        "Matching vibes to city profiles...",
        "Applying your constraints...",
    ]

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            // Cancel button
            HStack {
                Spacer()
                Button {
                    let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
                    analytics.trackButtonTap("cancel", screen: "clip_generating")
                    analytics.track("generation_cancelled", screen: "clip_generating", properties: [
                        "duration_ms": String(ms)
                    ])
                    withAnimation {
                        coordinator.currentScreen = .constraints
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(TeleportTheme.Colors.surface, in: Circle())
                }
            }
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .padding(.top, TeleportTheme.Spacing.md)

            Spacer()

            // Animated globe
            ZStack {
                Circle()
                    .stroke(TeleportTheme.Colors.border, lineWidth: 3)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(TeleportTheme.Colors.accent, lineWidth: 3)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)

                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(TeleportTheme.Colors.accent)
            }

            VStack(spacing: TeleportTheme.Spacing.sm) {
                Text("Finding Your Cities")
                    .font(TeleportTheme.Typography.title(22))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)

                Text(statusMessages[currentMessageIndex])
                    .font(TeleportTheme.Typography.body())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: currentMessageIndex)
            }

            if let error = coordinator.error {
                VStack(spacing: TeleportTheme.Spacing.md) {
                    Text(error)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TeleportTheme.Spacing.lg)

                    TeleportButton(title: "Try Again", style: .secondary) {
                        analytics.trackButtonTap("try_again", screen: "clip_generating")
                        coordinator.error = nil
                        Task { await coordinator.generate() }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.xxl)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TeleportTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("clip_generating")
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("clip_generating", durationMs: ms, exitType: coordinator.error != nil ? "failed" : "completed")
        }
        .task {
            // Animate progress and status messages while coordinator handles generation
            for i in 0..<statusMessages.count {
                try? await Task.sleep(for: .seconds(1.0))
                withAnimation {
                    currentMessageIndex = min(i, statusMessages.count - 1)
                    progress = CGFloat(i + 1) / CGFloat(statusMessages.count)
                }
            }
            // Hold at final message until coordinator completes
            while coordinator.currentScreen == .generating && coordinator.error == nil {
                try? await Task.sleep(for: .seconds(0.5))
            }
        }
    }
}
