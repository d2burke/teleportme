import SwiftUI

struct NameInputView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @FocusState private var isFocused: Bool

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
            isFocused = true
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        NameInputView()
    }
}
