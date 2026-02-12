import SwiftUI

struct GeneratingView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var progress: CGFloat = 0
    @State private var currentMessageIndex = 0
    @State private var error: String?

    private let statusMessages = [
        "Analyzing your preferences...",
        "Scanning 55 cities worldwide...",
        "Comparing lifestyle metrics...",
        "Finding your perfect matches...",
        "Generating personalized insights...",
    ]

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
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
                        self.error = nil
                        Task { await generateReport() }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.xxl)
                }
            }

            Spacer()
        }
        .background(TeleportTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            await generateReport()
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
            coordinator.advanceOnboarding(from: .generating)
        } catch {
            messageTask.cancel()
            self.error = "Something went wrong. Please try again."
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
