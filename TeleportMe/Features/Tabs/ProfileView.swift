import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var pastReports: [CityReport] = []
    @State private var isLoadingReports = false
    @State private var reportsError: String?
    @State private var selectedReport: CityReport?

    private var profile: UserProfile? {
        coordinator.authService.currentProfile
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
                        recentReportsSection
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
            .navigationDestination(item: $selectedReport) { report in
                ReportDetailView(report: report)
            }
        }
        .task {
            await loadReports()
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
                    label: "Cities Explored",
                    icon: "globe"
                )
                statCard(
                    value: "\(pastReports.count)",
                    label: "Reports Generated",
                    icon: "doc.text"
                )
                statCard(
                    value: "\(coordinator.reportService.currentReport?.matches.count ?? 0)",
                    label: "Matches Found",
                    icon: "heart.circle"
                )
            }
        }
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

    // MARK: - Recent Reports Section

    private var recentReportsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Recent Reports")

            if isLoadingReports {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(TeleportTheme.Colors.accent)
                    Spacer()
                }
                .padding(.vertical, TeleportTheme.Spacing.lg)
            } else if let error = reportsError {
                CardView {
                    VStack(spacing: TeleportTheme.Spacing.sm) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 24))
                            .foregroundStyle(.red.opacity(0.6))

                        Text("Couldn't load reports")
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        Text(error)
                            .font(TeleportTheme.Typography.caption())
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)

                        Button {
                            Task { await loadReports() }
                        } label: {
                            Text("Retry")
                                .font(TeleportTheme.Typography.cardTitle(14))
                                .foregroundStyle(TeleportTheme.Colors.background)
                                .padding(.horizontal, TeleportTheme.Spacing.lg)
                                .padding(.vertical, TeleportTheme.Spacing.sm)
                                .background(TeleportTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TeleportTheme.Spacing.sm)
                }
            } else if pastReports.isEmpty {
                CardView {
                    VStack(spacing: TeleportTheme.Spacing.sm) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)

                        Text("No reports yet")
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        Text("Generate your first city report to see it here")
                            .font(TeleportTheme.Typography.caption())
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TeleportTheme.Spacing.md)
                }
            } else {
                VStack(spacing: TeleportTheme.Spacing.sm) {
                    ForEach(pastReports) { report in
                        Button {
                            selectedReport = report
                        } label: {
                            reportRow(report)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func reportRow(_ report: CityReport) -> some View {
        CardView {
            HStack(spacing: TeleportTheme.Spacing.md) {
                // Date icon
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundStyle(TeleportTheme.Colors.accent)
                    .frame(width: 36, height: 36)
                    .background(TeleportTheme.Colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                // Report info
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text(formattedDate(report.createdAt))
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    HStack(spacing: TeleportTheme.Spacing.md) {
                        Label("\(report.results.count) matches", systemImage: "heart.circle")
                            .font(TeleportTheme.Typography.caption())
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)

                        if let cityId = report.currentCityId {
                            Label(cityName(for: cityId), systemImage: "mappin.circle")
                                .font(TeleportTheme.Typography.caption())
                                .foregroundStyle(TeleportTheme.Colors.textSecondary)
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

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
            SectionHeader(title: "Settings")

            VStack(spacing: TeleportTheme.Spacing.sm) {
                settingsRow(icon: "pencil.circle", title: "Edit Profile", comingSoon: true)
                settingsRow(icon: "bell", title: "Notifications", comingSoon: true)
                settingsRow(icon: "info.circle", title: "About TeleportMe", comingSoon: false, detail: "v1.0")
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
                }
            }
        }
    }

    // MARK: - Sign Out

    private var signOutSection: some View {
        TeleportButton(title: "Sign Out", style: .secondary) {
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

    // MARK: - Helpers

    private func loadReports() async {
        guard let userId = coordinator.authService.currentProfile?.id else { return }
        isLoadingReports = true
        reportsError = nil
        pastReports = await coordinator.reportService.loadReports(userId: userId)
        // If we got no reports and the service has an error, surface it
        if pastReports.isEmpty, let serviceError = coordinator.reportService.error {
            reportsError = serviceError
        }
        isLoadingReports = false
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func cityName(for cityId: String) -> String {
        coordinator.cityService.allCities.first { $0.id == cityId }?.name ?? cityId
    }
}

// MARK: - Preview

#Preview("Profile") {
    PreviewContainer {
        ProfileView()
    }
}
