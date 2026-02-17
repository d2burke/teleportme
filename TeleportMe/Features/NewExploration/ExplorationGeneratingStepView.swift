import SwiftUI

// MARK: - Exploration Generating Step

struct ExplorationGeneratingStepView: View {
    @Environment(AppCoordinator.self) private var coordinator

    let title: String
    let startType: StartType
    let baselineCityId: String?
    let preferences: UserPreferences
    var vibeTags: [String]? = nil
    var userVibeTags: [String]? = nil
    var compassVibes: [String: Double]? = nil
    var compassConstraints: TripConstraints? = nil
    let onComplete: (GenerateReportResponse) -> Void
    let onError: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var progress: CGFloat = 0
    @State private var currentMessageIndex = 0
    @State private var error: String?
    @State private var generationTask: Task<Void, Never>?

    private var statusMessages: [String] {
        if compassVibes != nil {
            return [
                "Reading your signal weights...",
                "Scanning 400+ cities worldwide...",
                "Matching vibes to city profiles...",
                "Applying your constraints...",
                "Generating personalized insights...",
            ]
        }
        return [
            "Analyzing your preferences...",
            "Scanning 400+ cities worldwide...",
            "Comparing lifestyle metrics...",
            "Finding your perfect matches...",
            "Generating personalized insights...",
        ]
    }

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            // Cancel button
            HStack {
                Spacer()
                Button {
                    generationTask?.cancel()
                    dismiss()
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
                Text("Creating \"\(title)\"")
                    .font(TeleportTheme.Typography.title(22))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, TeleportTheme.Spacing.lg)

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
                        Task { await generate() }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.xxl)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TeleportTheme.Colors.backgroundElevated.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            generationTask = Task { await generate() }
            await generationTask?.value
        }
    }

    private func generate() async {
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

        let userId = coordinator.currentUserId

        do {
            let response = try await coordinator.explorationService.generateExploration(
                title: title,
                startType: startType,
                baselineCityId: baselineCityId,
                preferences: preferences,
                vibeTags: vibeTags,
                userVibeTags: userVibeTags,
                compassVibes: compassVibes,
                compassConstraints: compassConstraints,
                userId: userId
            )

            // Also update reportService for backward compat
            coordinator.reportService.currentReport = response
            if let userId {
                CacheManager.shared.save(response, for: .currentReport(userId: userId))
            }

            messageTask.cancel()

            await MainActor.run {
                withAnimation { progress = 1.0 }
            }

            try? await Task.sleep(for: .seconds(0.5))
            onComplete(response)
        } catch {
            messageTask.cancel()
            #if DEBUG
            self.error = "Error: \(error.localizedDescription)"
            #else
            self.error = "Something went wrong. Please try again."
            #endif
            onError(error.localizedDescription)
            print("Exploration generation failed: \(error)")
        }
    }
}
