import SwiftUI

struct NameInputView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @FocusState private var isFocused: Bool
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    var body: some View {
        @Bindable var coord = coordinator

        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: TeleportTheme.Spacing.xxl) {
                Text("First things first,\nwhat's your name?")
                    .font(TeleportTheme.Typography.title(24))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                TextField("Name", text: $coord.onboardingName)
                    .font(TeleportTheme.Typography.heroTitle(36))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .tint(TeleportTheme.Colors.accent)
            }

            Spacer()

            // Continue button (hidden until name entered)
            if !coordinator.onboardingName.trimmingCharacters(in: .whitespaces).isEmpty {
                TeleportButton(title: "Continue", icon: "arrow.right") {
                    analytics.trackButtonTap("continue", screen: "name_input")
                    analytics.track("onboarding_step_completed", screen: "name_input", properties: [
                        "step": "name",
                        "duration_ms": String(Int(Date().timeIntervalSince(screenEnteredAt) * 1000))
                    ])
                    coordinator.advanceOnboarding(from: .name)
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.bottom, TeleportTheme.Spacing.lg)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(TeleportTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.spring(response: 0.4), value: coordinator.onboardingName.isEmpty)
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("name_input")
            isFocused = true
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("name_input", durationMs: ms, exitType: "advanced")
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        NameInputView()
    }
}
