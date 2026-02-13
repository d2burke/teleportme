import SwiftUI

struct SignInView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var screenEnteredAt = Date()
    @FocusState private var focusedField: Field?
    private let analytics = AnalyticsService.shared

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
                        analytics.trackButtonTap("sign_in", screen: "sign_in")
                        analytics.track("signin_attempted", screen: "sign_in")
                        Task { await signIn() }
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.5)
                    .padding(.horizontal, TeleportTheme.Spacing.lg)

                    Button {
                        analytics.trackButtonTap("sign_up_link", screen: "sign_in")
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
                analytics.trackButtonTap("dismiss", screen: "sign_in")
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
            screenEnteredAt = Date()
            analytics.trackScreenView("sign_in")
            focusedField = .email
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("sign_in", durationMs: ms, exitType: "advanced")
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
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.track("signin_succeeded", screen: "sign_in", properties: ["duration_ms": String(ms)])
            // Load cities in background after sign-in
            Task { await coordinator.cityService.fetchAllCities() }
            coordinator.goToMain()
            dismiss()
        } catch {
            let errorType: String
            let desc = error.localizedDescription.lowercased()
            if desc.contains("invalid") || desc.contains("credentials") { errorType = "invalid_credentials" }
            else if desc.contains("network") || desc.contains("connection") { errorType = "network" }
            else if desc.contains("rate") { errorType = "rate_limited" }
            else { errorType = "unknown" }
            analytics.track("signin_failed", screen: "sign_in", properties: ["error_type": errorType])
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
