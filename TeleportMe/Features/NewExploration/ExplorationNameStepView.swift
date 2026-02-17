import SwiftUI

// MARK: - Exploration Name Step

struct ExplorationNameStepView: View {
    @Binding var title: String
    let onContinue: () -> Void
    let onDismiss: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: TeleportTheme.Spacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "text.cursor")
                .font(.system(size: 48))
                .foregroundStyle(TeleportTheme.Colors.accent)

            // Title
            VStack(spacing: TeleportTheme.Spacing.sm) {
                Text("Name Your Exploration")
                    .font(TeleportTheme.Typography.title(26))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Give it a name like \"Beach Vibes\" or \"Adventure Trip with the Boys\"")
                    .font(TeleportTheme.Typography.body(15))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
            }

            // Text field
            TextField("e.g., Dream City Search", text: $title)
                .font(TeleportTheme.Typography.title(20))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .tint(TeleportTheme.Colors.accent)
                .focused($isFocused)
                .padding(.vertical, TeleportTheme.Spacing.md)
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
                .padding(.horizontal, TeleportTheme.Spacing.xl)

            // Skip hint
            Text("Or skip to use a default name")
                .font(TeleportTheme.Typography.caption(13))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)

            Spacer()
            Spacer()
        }
        .background(TeleportTheme.Colors.backgroundElevated)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onDismiss() }
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }
        }
        .overlay(alignment: .bottom) {
            TeleportButton(title: "Continue", icon: "arrow.right") {
                onContinue()
            }
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
        .onAppear {
            isFocused = true
        }
    }
}
