import SwiftUI

struct SignUpView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email, password, confirm
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: TeleportTheme.Spacing.xl) {
                Text("Let's set up your profile\nand preferences")
                    .font(TeleportTheme.Typography.title(22))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                VStack(spacing: TeleportTheme.Spacing.md) {
                    // Email field
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        Text("Email")
                            .font(TeleportTheme.Typography.caption(12))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)

                        TextField("", text: $email)
                            .font(TeleportTheme.Typography.body(16))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .tint(TeleportTheme.Colors.accent)
                    }
                    .padding(TeleportTheme.Spacing.md)
                    .background(TeleportTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))

                    // Password field
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        Text("Password")
                            .font(TeleportTheme.Typography.caption(12))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)

                        SecureField("", text: $password)
                            .font(TeleportTheme.Typography.body(16))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                            .focused($focusedField, equals: .password)
                            .tint(TeleportTheme.Colors.accent)
                    }
                    .padding(TeleportTheme.Spacing.md)
                    .background(TeleportTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))

                    // Confirm password
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        Text("Repeat Password")
                            .font(TeleportTheme.Typography.caption(12))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)

                        SecureField("", text: $confirmPassword)
                            .font(TeleportTheme.Typography.body(16))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                            .focused($focusedField, equals: .confirm)
                            .tint(TeleportTheme.Colors.accent)
                    }
                    .padding(TeleportTheme.Spacing.md)
                    .background(TeleportTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)

                if showError {
                    Text(errorMessage)
                        .font(TeleportTheme.Typography.caption(13))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
            }

            Spacer()

            TeleportButton(
                title: "Create my account",
                isLoading: coordinator.authService.isLoading
            ) {
                Task { await createAccount() }
            }
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)
            .padding(.horizontal, TeleportTheme.Spacing.lg)
            .padding(.bottom, TeleportTheme.Spacing.lg)
        }
        .background(TeleportTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            focusedField = .email
        }
    }

    private func createAccount() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields. Password must be at least 6 characters."
            showError = true
            return
        }

        // In preview mode, skip actual auth and just advance
        if coordinator.previewMode {
            Task { await coordinator.cityService.fetchAllCities() }
            coordinator.advanceOnboarding(from: .signUp)
            return
        }

        do {
            try await coordinator.authService.signUp(
                email: email,
                password: password,
                name: coordinator.onboardingName
            )
            // Load cities in background after signup
            Task { await coordinator.cityService.fetchAllCities() }
            coordinator.advanceOnboarding(from: .signUp)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        SignUpView()
    }
}
