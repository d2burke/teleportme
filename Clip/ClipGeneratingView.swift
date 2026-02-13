import SwiftUI

// MARK: - Clip Generating View

struct ClipGeneratingView: View {
    @Environment(ClipCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var progress: CGFloat = 0
    @State private var currentMessageIndex = 0
    @State private var error: String?
    @State private var generationTask: Task<Void, Never>?
    @State private var generationStartedAt: Date?

    private let statusMessages = [
        "Analyzing your preferences...",
        "Scanning cities worldwide...",
        "Comparing lifestyle metrics...",
        "Finding your matches...",
    ]

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            // Cancel button
            HStack {
                Spacer()
                Button {
                    let ms = generationStartedAt.map { Int(Date().timeIntervalSince($0) * 1000) }
                    analytics.trackButtonTap("cancel", screen: "clip_generating")
                    analytics.track("generation_cancelled", screen: "clip_generating", properties: ms.map { ["duration_ms": String($0)] } ?? [:])
                    generationTask?.cancel()
                    withAnimation {
                        coordinator.currentScreen = .preferences
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

            if let error {
                VStack(spacing: TeleportTheme.Spacing.md) {
                    Text(error)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TeleportTheme.Spacing.lg)

                    TeleportButton(title: "Try Again", style: .secondary) {
                        analytics.trackButtonTap("try_again", screen: "clip_generating")
                        self.error = nil
                        Task { await generate() }
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
            analytics.trackScreenExit("clip_generating", durationMs: ms, exitType: error != nil ? "failed" : "completed")
        }
        .task {
            generationTask = Task { await generate() }
            await generationTask?.value
        }
    }

    private func generate() async {
        generationStartedAt = Date()
        analytics.track("generation_started", screen: "clip_generating", properties: ["source": "clip"])

        // Animate progress and status messages
        let messageTask = Task {
            for i in 0..<statusMessages.count {
                try? await Task.sleep(for: .seconds(1.0))
                await MainActor.run {
                    withAnimation {
                        currentMessageIndex = min(i, statusMessages.count - 1)
                        progress = CGFloat(i + 1) / CGFloat(statusMessages.count)
                    }
                }
            }
        }

        do {
            let response = try await coordinator.explorationService.generateExploration(
                title: "Quick Exploration",
                startType: .cityILove,
                baselineCityId: nil,
                preferences: coordinator.preferences,
                userId: nil
            )

            messageTask.cancel()

            await MainActor.run {
                withAnimation { progress = 1.0 }
            }

            try? await Task.sleep(for: .seconds(0.3))

            let ms = Int(Date().timeIntervalSince(generationStartedAt ?? Date()) * 1000)
            analytics.track("clip_generation_completed", screen: "clip_generating", properties: [
                "duration_ms": String(ms),
                "match_count": String(response.matches.count)
            ])

            await MainActor.run {
                coordinator.generatedResponse = response
                coordinator.currentScreen = .results
            }
        } catch {
            messageTask.cancel()
            let ms = Int(Date().timeIntervalSince(generationStartedAt ?? Date()) * 1000)
            let errorType = if Task.isCancelled { "cancelled" }
                else if error.localizedDescription.contains("timed out") { "timeout" }
                else if error.localizedDescription.contains("network") || error.localizedDescription.contains("internet") { "network" }
                else { "server_error" }
            analytics.track("clip_generation_failed", screen: "clip_generating", properties: [
                "error_type": errorType,
                "duration_ms": String(ms)
            ])
            self.error = "Something went wrong. Please try again."
            print("Clip generation failed: \(error)")
        }
    }
}
