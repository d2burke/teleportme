import SwiftUI

struct SplashView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var cardsAppeared = false
    @State private var textAppeared = false
    @State private var showSignIn = false
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared
    #if DEBUG
    @State private var showDevMode = false
    #endif

    var body: some View {
        ZStack {
            TeleportTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    // Logo mark (three bars like the Figma)
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i == 0 ? TeleportTheme.Colors.accent : TeleportTheme.Colors.textPrimary)
                                .frame(width: 4, height: i == 1 ? 20 : 14)
                        }
                    }
                    #if DEBUG
                    .onLongPressGesture(minimumDuration: 1) {
                        showDevMode = true
                    }
                    #endif

                    Spacer()

                    Button("Sign in") {
                        analytics.trackButtonTap("sign_in", screen: "splash")
                        showSignIn = true
                    }
                    .font(TeleportTheme.Typography.cardTitle(15))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.top, TeleportTheme.Spacing.md)

                Spacer()

                // Stacked city cards
                ZStack {
                    // Back cards (offset and rotated)
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.large)
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 240, height: 300)
                        .rotationEffect(.degrees(8))
                        .offset(x: 20, y: -10)

                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.large)
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 240, height: 300)
                        .rotationEffect(.degrees(-5))
                        .offset(x: -15, y: -5)

                    // Front card with image
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=600&q=80")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(TeleportTheme.Colors.surface)
                        }
                    }
                    .frame(width: 260, height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.large))
                    .overlay(alignment: .center) {
                        // Heart icon
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .scaleEffect(cardsAppeared ? 1 : 0.8)
                .opacity(cardsAppeared ? 1 : 0)

                Spacer()

                // Title + CTA
                VStack(spacing: TeleportTheme.Spacing.lg) {
                    VStack(spacing: TeleportTheme.Spacing.xs) {
                        Text("Meet your ideal city")
                            .font(TeleportTheme.Typography.title(28))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        Text("in minutes")
                            .font(TeleportTheme.Typography.title(28))
                            .foregroundStyle(TeleportTheme.Colors.accent)
                    }
                    .opacity(textAppeared ? 1 : 0)
                    .offset(y: textAppeared ? 0 : 20)

                    TeleportButton(title: "Let's roll") {
                        analytics.trackButtonTap("lets_roll", screen: "splash")
                        coordinator.startOnboarding()
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                    .opacity(textAppeared ? 1 : 0)
                }
                .padding(.bottom, TeleportTheme.Spacing.xxl)
            }
        }
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("splash")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                cardsAppeared = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                textAppeared = true
            }
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("splash", durationMs: ms, exitType: "advanced")
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environment(coordinator)
        }
        #if DEBUG
        .sheet(isPresented: $showDevMode) {
            DevModeView()
                .environment(coordinator)
        }
        #endif
    }
}

// MARK: - Preview

#Preview {
    PreviewContainer {
        SplashView()
    }
}
