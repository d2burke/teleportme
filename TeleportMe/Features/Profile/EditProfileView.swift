import SwiftUI

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var displayName: String = ""
    @State private var selectedCityId: String? = nil
    @State private var selectedCityName: String? = nil
    @State private var preferences: UserPreferences = .defaults
    @State private var isSaving = false
    @State private var showCityPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xl) {
                    // Display Name
                    nameSection

                    // Home City
                    homeCitySection

                    // Default Preferences
                    preferencesSection
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.vertical, TeleportTheme.Spacing.md)
                .padding(.bottom, 100)
            }
            .background(TeleportTheme.Colors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }
            .overlay(alignment: .bottom) {
                TeleportButton(title: "Save Changes", icon: "checkmark", isLoading: isSaving) {
                    analytics.trackButtonTap("save", screen: "edit_profile")
                    Task { await saveChanges() }
                }
                .disabled(isSaving)
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.bottom, TeleportTheme.Spacing.lg)
                .background(
                    LinearGradient(
                        colors: [TeleportTheme.Colors.background.opacity(0), TeleportTheme.Colors.background],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            }
            .sheet(isPresented: $showCityPicker) {
                CityPickerSheet(
                    selectedCityId: $selectedCityId,
                    selectedCityName: $selectedCityName
                )
            }
            .onAppear {
                screenEnteredAt = Date()
                analytics.trackScreenView("edit_profile")
                loadCurrentValues()
            }
            .onDisappear {
                let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
                analytics.trackScreenExit("edit_profile", durationMs: ms, exitType: "back")
            }
        }
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            Text("DISPLAY NAME")
                .font(TeleportTheme.Typography.sectionHeader())
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                .tracking(1.5)

            TextField("Your name", text: $displayName)
                .font(TeleportTheme.Typography.body())
                .foregroundStyle(TeleportTheme.Colors.textPrimary)
                .tint(TeleportTheme.Colors.accent)
                .textInputAutocapitalization(.words)
                .padding(TeleportTheme.Spacing.md)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
        }
    }

    // MARK: - Home City Section

    private var homeCitySection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            Text("HOME CITY")
                .font(TeleportTheme.Typography.sectionHeader())
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                .tracking(1.5)

            Button {
                showCityPicker = true
            } label: {
                HStack(spacing: TeleportTheme.Spacing.md) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(TeleportTheme.Colors.accent)

                    Text(selectedCityName ?? "No home city set")
                        .font(TeleportTheme.Typography.body())
                        .foregroundStyle(
                            selectedCityName != nil
                                ? TeleportTheme.Colors.textPrimary
                                : TeleportTheme.Colors.textTertiary
                        )

                    Spacer()

                    if selectedCityId != nil {
                        Button {
                            selectedCityId = nil
                            selectedCityName = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                }
                .padding(TeleportTheme.Spacing.md)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            Text("DEFAULT PREFERENCES")
                .font(TeleportTheme.Typography.sectionHeader())
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                .tracking(1.5)

            Text("These defaults will be pre-filled when you create new explorations. Tap \(Image(systemName: "info.circle")) to learn more.")
                .font(TeleportTheme.Typography.caption(13))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)

            PreferenceSlidersList(preferences: $preferences, animated: false)
        }
    }

    // MARK: - Load / Save

    private func loadCurrentValues() {
        displayName = coordinator.authService.currentProfile?.name ?? ""
        preferences = coordinator.preferences

        // Load current home city
        if let cityId = coordinator.selectedCityId {
            selectedCityId = cityId
            selectedCityName = coordinator.cityService.allCities.first { $0.id == cityId }?.name
        }
    }

    private func saveChanges() async {
        isSaving = true
        defer { isSaving = false }

        // Update preferences on coordinator
        coordinator.preferences = preferences
        await coordinator.savePreferences()

        // Update profile name
        if !displayName.isEmpty {
            try? await coordinator.authService.updateProfile(name: displayName)
        }

        // Update home city
        if let cityId = selectedCityId {
            await coordinator.selectCity(cityId)
        } else if coordinator.selectedCityId != nil {
            // User cleared their city
            coordinator.selectedCityId = nil
            coordinator.selectedCity = nil
        }

        dismiss()
    }
}

// MARK: - City Picker Sheet

private struct CityPickerSheet: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCityId: String?
    @Binding var selectedCityName: String?

    @State private var searchText = ""
    @State private var searchResults: [City] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TeleportTheme.Spacing.md) {
                    // Search bar
                    HStack(spacing: TeleportTheme.Spacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        TextField("Search cities", text: $searchText)
                            .font(TeleportTheme.Typography.body())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                            .autocorrectionDisabled()
                            .tint(TeleportTheme.Colors.accent)
                    }
                    .padding(TeleportTheme.Spacing.md)
                    .background(TeleportTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                    .overlay {
                        RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                            .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                    .onChange(of: searchText) { _, newValue in
                        Task { await performSearch(query: newValue) }
                    }

                    // Results
                    let cities = searchText.isEmpty
                        ? coordinator.cityService.allCities
                        : searchResults

                    ForEach(cities) { city in
                        Button {
                            selectedCityId = city.id
                            selectedCityName = city.name
                            dismiss()
                        } label: {
                            CitySearchRow(city: city) {}
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
                .padding(.top, TeleportTheme.Spacing.md)
            }
            .background(TeleportTheme.Colors.background)
            .navigationTitle("Choose City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }
        }
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        searchResults = await coordinator.cityService.searchCities(query: query)
    }
}
