import SwiftUI

struct SignUpView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var screenEnteredAt = Date()
    @FocusState private var focusedField: Field?
    private let analytics = AnalyticsService.shared

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

                    // Inline validation hints
                    if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                        HStack(spacing: TeleportTheme.Spacing.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text("Passwords don't match")
                        }
                        .font(TeleportTheme.Typography.caption(12))
                        .foregroundStyle(.red.opacity(0.8))
                    } else if !password.isEmpty && password.count < 6 {
                        HStack(spacing: TeleportTheme.Spacing.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text("Password must be at least 6 characters")
                        }
                        .font(TeleportTheme.Typography.caption(12))
                        .foregroundStyle(.red.opacity(0.8))
                    }
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
                analytics.trackButtonTap("create_account", screen: "sign_up")
                analytics.track("signup_attempted", screen: "sign_up")
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
            screenEnteredAt = Date()
            analytics.trackScreenView("sign_up")
            focusedField = .email
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("sign_up", durationMs: ms, exitType: "advanced")
        }
    }

    private func createAccount() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields. Password must be at least 6 characters."
            showError = true
            analytics.track("signup_failed", screen: "sign_up", properties: ["error_type": "validation"])
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
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.track("signup_succeeded", screen: "sign_up", properties: ["duration_ms": String(ms)])
            // Load cities in background after signup
            Task { await coordinator.cityService.fetchAllCities() }
            coordinator.advanceOnboarding(from: .signUp)
        } catch {
            let errorType: String
            let desc = error.localizedDescription.lowercased()
            if desc.contains("password") { errorType = "weak_password" }
            else if desc.contains("already") || desc.contains("duplicate") { errorType = "duplicate_email" }
            else if desc.contains("network") || desc.contains("connection") { errorType = "network" }
            else if desc.contains("rate") { errorType = "rate_limited" }
            else { errorType = "unknown" }
            analytics.track("signup_failed", screen: "sign_up", properties: ["error_type": errorType])
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
