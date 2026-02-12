import SwiftUI

struct SignInView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email, password
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TeleportTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: TeleportTheme.Spacing.xl) {
                    Text("Welcome back")
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

                VStack(spacing: TeleportTheme.Spacing.md) {
                    TeleportButton(
                        title: "Sign In",
                        isLoading: coordinator.authService.isLoading
                    ) {
                        Task { await signIn() }
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.5)
                    .padding(.horizontal, TeleportTheme.Spacing.lg)

                    Button {
                        dismiss()
                        coordinator.startOnboarding()
                    } label: {
                        HStack(spacing: TeleportTheme.Spacing.xs) {
                            Text("Don't have an account?")
                                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                            Text("Sign up")
                                .foregroundStyle(TeleportTheme.Colors.accent)
                        }
                        .font(TeleportTheme.Typography.caption(14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, TeleportTheme.Spacing.lg)
            }

            // Close button (top-left)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(TeleportTheme.Colors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.leading, TeleportTheme.Spacing.lg)
            .padding(.top, TeleportTheme.Spacing.md)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            focusedField = .email
        }
    }

    private func signIn() async {
        guard isFormValid else { return }

        showError = false

        // In preview mode, skip actual auth and just advance
        if coordinator.previewMode {
            Task { await coordinator.cityService.fetchAllCities() }
            coordinator.goToMain()
            dismiss()
            return
        }

        do {
            try await coordinator.authService.signIn(
                email: email,
                password: password
            )
            // Load cities in background after sign-in
            Task { await coordinator.cityService.fetchAllCities() }
            coordinator.goToMain()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        SignInView()
    }
}
