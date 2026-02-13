import SwiftUI

struct GeneratingView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var progress: CGFloat = 0
    @State private var currentMessageIndex = 0
    @State private var error: String?
    @State private var generationTask: Task<Void, Never>?
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    private let statusMessages = [
        "Analyzing your preferences...",
        "Scanning 55 cities worldwide...",
        "Comparing lifestyle metrics...",
        "Finding your perfect matches...",
        "Generating personalized insights...",
    ]

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            // Cancel button
            HStack {
                Spacer()
                Button {
                    let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
                    analytics.trackButtonTap("cancel", screen: "generating")
                    analytics.track("generation_cancelled", screen: "generating", properties: ["duration_ms": String(ms)])
                    generationTask?.cancel()
                    coordinator.goBackOnboarding(from: .generating)
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
                    .font(TeleportTheme.Typography.title(24))
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

                    TeleportButton(title: "Try Again", style: .secondary) {
                        analytics.trackButtonTap("try_again", screen: "generating")
                        self.error = nil
                        Task { await generateReport() }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.xxl)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TeleportTheme.Colors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("generating")
            analytics.track("generation_started", screen: "generating", properties: ["source": "onboarding"])
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("generating", durationMs: ms, exitType: error != nil ? "failed" : "completed")
        }
        .task {
            generationTask = Task { await generateReport() }
            await generationTask?.value
        }
    }

    private func generateReport() async {
        // Animate progress and status messages
        let messageTask = Task {
            for i in 0..<statusMessages.count {
                try? await Task.sleep(for: .seconds(1.2))
                await MainActor.run {
                    withAnimation {
                        currentMessageIndex = min(i, statusMessages.count - 1)
                        progress = CGFloat(i + 1) / CGFloat(statusMessages.count)
                    }
                }
            }
        }

        do {
            let _ = try await coordinator.generateReport()
            messageTask.cancel()

            await MainActor.run {
                withAnimation {
                    progress = 1.0
                }
            }

            // Brief pause to show completion
            try? await Task.sleep(for: .seconds(0.5))
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.track("generation_completed", screen: "generating", properties: [
                "duration_ms": String(ms),
                "source": "onboarding"
            ])
            coordinator.advanceOnboarding(from: .generating)
        } catch {
            messageTask.cancel()
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            let errorType: String
            let desc = error.localizedDescription.lowercased()
            if desc.contains("timeout") { errorType = "timeout" }
            else if desc.contains("network") || desc.contains("connection") { errorType = "network" }
            else if desc.contains("edge") || desc.contains("function") { errorType = "edge_function_error" }
            else { errorType = "server_error" }
            analytics.track("generation_failed", screen: "generating", properties: [
                "error_type": errorType, "duration_ms": String(ms)
            ])
            #if DEBUG
            self.error = "Error: \(error.localizedDescription)"
            #else
            self.error = "Something went wrong. Please try again."
            #endif
            print("Report generation failed: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        GeneratingView()
    }
}
