import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var showEditProfile = false

    private var profile: UserProfile? {
        coordinator.authService.currentProfile
    }

    private var explorations: [Exploration] {
        coordinator.explorationService.explorations
    }

    private var initials: String {
        guard let name = profile?.name, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TeleportTheme.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TeleportTheme.Spacing.lg) {
                        headerSection
                        statsSection
                        recentExplorationsSection
                        settingsSection
                        signOutSection
                        versionFooter
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.md)
                    .padding(.vertical, TeleportTheme.Spacing.lg)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Exploration.self) { exploration in
                ExplorationDetailView(exploration: exploration)
            }
            .onAppear {
                screenEnteredAt = Date()
                analytics.trackScreenView("profile")
            }
            .onDisappear {
                let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
                analytics.trackScreenExit("profile", durationMs: ms, exitType: "tab_switch")
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: TeleportTheme.Spacing.md) {
            // Avatar circle with initials
            Text(initials)
                .font(TeleportTheme.Typography.title(24))
                .foregroundStyle(TeleportTheme.Colors.background)
                .frame(width: 80, height: 80)
                .background(TeleportTheme.Colors.accent)
                .clipShape(Circle())

            // Name
            Text(profile?.name ?? "User")
                .font(TeleportTheme.Typography.title(28))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)

            // Email
            if let email = profile?.email {
                Text(email)
                    .font(TeleportTheme.Typography.body())
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TeleportTheme.Spacing.md)
    }

    // MARK: - My Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "My Stats")

            HStack(spacing: TeleportTheme.Spacing.sm) {
                statCard(
                    value: "\(coordinator.savedCitiesService.savedCities.count)",
                    label: "Saved Cities",
                    icon: "heart"
                )
                statCard(
                    value: "\(explorations.count)",
                    label: "Explorations",
                    icon: "safari"
                )
                statCard(
                    value: "\(totalCitiesExplored)",
                    label: "Cities Found",
                    icon: "globe"
                )
            }
        }
    }

    private var totalCitiesExplored: Int {
        let allCityIds = Set(explorations.flatMap { $0.results.map(\.cityId) })
        return allCityIds.count
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        CardView {
            VStack(spacing: TeleportTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(TeleportTheme.Colors.accent)

                Text(value)
                    .font(TeleportTheme.Typography.scoreValue(24))
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)

                Text(label)
                    .font(TeleportTheme.Typography.caption(11))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Recent Explorations Section

    private var recentExplorationsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Your Explorations")

            if explorations.isEmpty {
                CardView {
                    VStack(spacing: TeleportTheme.Spacing.sm) {
                        Image(systemName: "safari")
                            .font(.system(size: 32))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)

                        Text("No explorations yet")
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        Text("Create your first exploration to see it here")
                            .font(TeleportTheme.Typography.caption())
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TeleportTheme.Spacing.md)
                }
            } else {
                VStack(spacing: TeleportTheme.Spacing.sm) {
                    ForEach(explorations.prefix(5)) { exploration in
                        NavigationLink(value: exploration) {
                            explorationRow(exploration)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func explorationRow(_ exploration: Exploration) -> some View {
        CardView {
            HStack(spacing: TeleportTheme.Spacing.md) {
                // Start type icon
                Image(systemName: startTypeIcon(exploration.startType))
                    .font(.system(size: 18))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(TeleportTheme.Colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                // Exploration info
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text(exploration.title)
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: TeleportTheme.Spacing.md) {
                        Label("\(exploration.results.count) cities", systemImage: "globe")
                            .font(TeleportTheme.Typography.caption())
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)

                        if let date = exploration.createdAt {
                            Text(date, style: .date)
                                .font(TeleportTheme.Typography.caption())
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TeleportTheme.Colors.textTertiary)
            }
        }
    }

    private func startTypeIcon(_ startType: StartType) -> String {
        switch startType {
        case .cityILove: return "heart.fill"
        case .vibes: return "waveform"
        case .myWords: return "text.quote"
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Settings")

            VStack(spacing: TeleportTheme.Spacing.sm) {
                Button {
                    analytics.trackButtonTap("edit_profile", screen: "profile")
                    showEditProfile = true
                } label: {
                    settingsRow(icon: "pencil.circle", title: "Edit Profile")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    SavedView()
                        .navigationTitle("Saved Cities")
                } label: {
                    settingsRow(icon: "heart.circle", title: "Saved Cities")
                }
                .buttonStyle(.plain)

                settingsRow(icon: "bell", title: "Notifications", comingSoon: true)
                settingsRow(icon: "info.circle", title: "About TeleportMe", detail: "v1.0")
            }
        }
    }

    private func settingsRow(icon: String, title: String, comingSoon: Bool = false, detail: String? = nil) -> some View {
        CardView {
            HStack(spacing: TeleportTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(TeleportTheme.Colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                Text(title)
                    .font(TeleportTheme.Typography.cardTitle())
                    .foregroundStyle(TeleportTheme.Colors.textPrimary)

                Spacer()

                if comingSoon {
                    Text("Coming Soon")
                        .font(TeleportTheme.Typography.caption(11))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        .padding(.horizontal, TeleportTheme.Spacing.sm)
                        .padding(.vertical, 3)
                        .background(TeleportTheme.Colors.surfaceElevated)
                        .clipShape(Capsule())
                } else if let detail {
                    Text(detail)
                        .font(TeleportTheme.Typography.caption())
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }
            }
        }
    }

    // MARK: - Sign Out

    private var signOutSection: some View {
        TeleportButton(title: "Sign Out", style: .secondary) {
            analytics.trackButtonTap("sign_out", screen: "profile")
            analytics.track("sign_out_completed", screen: "profile", properties: [
                "explorations_count": String(explorations.count),
                "saved_count": String(coordinator.savedCitiesService.savedCities.count)
            ])
            Task {
                await coordinator.signOut()
            }
        }
        .padding(.top, TeleportTheme.Spacing.sm)
    }

    // MARK: - Version Footer

    private var versionFooter: some View {
        Text("TeleportMe v1.0")
            .font(TeleportTheme.Typography.caption())
            .foregroundStyle(TeleportTheme.Colors.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, TeleportTheme.Spacing.sm)
            .padding(.bottom, TeleportTheme.Spacing.md)
    }
}

// MARK: - Preview

#Preview("Profile") {
    PreviewContainer {
        ProfileView()
    }
}
