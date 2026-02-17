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
    @State private var selectedVibeIds: Set<String> = []
    @State private var allVibeTags: [VibeTag] = []
    @State private var isSaving = false
    @State private var showCityPicker = false
    @State private var showVibeEditor = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xl) {
                    // Display Name
                    nameSection

                    // Home City
                    homeCitySection

                    // Your Heading (Compass)
                    headingSection

                    // Your Vibes
                    vibesSection

                    // Default Preferences
                    preferencesSection
                }
                .padding(.horizontal, TeleportTheme.Spacing.lg)
                .padding(.vertical, TeleportTheme.Spacing.md)
                .padding(.bottom, 100)
            }
            .background(TeleportTheme.Colors.backgroundElevated)
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
                        colors: [TeleportTheme.Colors.backgroundElevated.opacity(0), TeleportTheme.Colors.backgroundElevated],
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
            .sheet(isPresented: $showVibeEditor) {
                NavigationStack {
                    VibeSelectionView(
                        selectedVibeIds: $selectedVibeIds,
                        onContinue: {
                            showVibeEditor = false
                        }
                    )
                    .navigationTitle("Edit Vibes")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showVibeEditor = false }
                                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        }
                    }
                }
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

    // MARK: - Heading Section

    private var headingSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            Text("YOUR HEADING")
                .font(TeleportTheme.Typography.sectionHeader())
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                .tracking(1.5)

            if let weights = coordinator.preferences.signalWeights, !weights.isEmpty {
                let heading = HeadingEngine.heading(fromRaw: weights)

                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                    // Heading badge
                    HStack(spacing: TeleportTheme.Spacing.md) {
                        Text(heading.emoji)
                            .font(.system(size: 28))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(heading.name)
                                .font(TeleportTheme.Typography.cardTitle(17))
                                .foregroundStyle(TeleportTheme.Colors.textPrimary)

                            if !heading.topSignals.isEmpty {
                                HStack(spacing: TeleportTheme.Spacing.xs) {
                                    ForEach(heading.topSignals) { signal in
                                        HStack(spacing: 3) {
                                            Text(signal.emoji)
                                                .font(.system(size: 11))
                                            Text(signal.label)
                                                .font(TeleportTheme.Typography.caption(11))
                                                .foregroundStyle(signal.color)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(signal.color.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        Spacer()
                    }

                    // Reset button
                    Button {
                        analytics.trackButtonTap("reset_heading", screen: "edit_profile")
                        coordinator.preferences.signalWeights = nil
                    } label: {
                        HStack(spacing: TeleportTheme.Spacing.xs) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12))
                            Text("Reset Heading")
                                .font(TeleportTheme.Typography.caption(13))
                        }
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(TeleportTheme.Spacing.md)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
            } else {
                // No heading yet
                HStack(spacing: TeleportTheme.Spacing.md) {
                    Image(systemName: "safari")
                        .font(.system(size: 20))
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("No heading yet")
                            .font(TeleportTheme.Typography.body())
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        Text("Create an exploration to discover your heading")
                            .font(TeleportTheme.Typography.caption(12))
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    }

                    Spacer()
                }
                .padding(TeleportTheme.Spacing.md)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
            }
        }
    }

    // MARK: - Vibes Section

    private var vibesSection: some View {
        VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
            Text("YOUR VIBES")
                .font(TeleportTheme.Typography.sectionHeader())
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                .tracking(1.5)

            Text("These vibes will be pre-filled when you create new explorations.")
                .font(TeleportTheme.Typography.caption(13))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)

            if selectedVibeIds.isEmpty {
                // Empty state
                Button {
                    analytics.trackButtonTap("add_vibes", screen: "edit_profile")
                    showVibeEditor = true
                } label: {
                    HStack(spacing: TeleportTheme.Spacing.md) {
                        Image(systemName: "waveform")
                            .font(.system(size: 20))
                            .foregroundStyle(TeleportTheme.Colors.accent)

                        Text("No vibes selected yet")
                            .font(TeleportTheme.Typography.body())
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)

                        Spacer()

                        Text("Add Vibes")
                            .font(TeleportTheme.Typography.caption(13))
                            .foregroundStyle(TeleportTheme.Colors.accent)

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
            } else {
                // Selected vibes display
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.md) {
                    FlowLayout(spacing: TeleportTheme.Spacing.sm) {
                        ForEach(selectedVibeDisplayTags, id: \.id) { tag in
                            HStack(spacing: 4) {
                                Text("\(tag.emoji ?? "") \(tag.name)")
                                    .font(TeleportTheme.Typography.caption(14))

                                Button {
                                    selectedVibeIds.remove(tag.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                }
                                .buttonStyle(.plain)
                            }
                            .foregroundStyle(TeleportTheme.Colors.backgroundElevated)
                            .padding(.horizontal, TeleportTheme.Spacing.md)
                            .padding(.vertical, TeleportTheme.Spacing.sm)
                            .background(TeleportTheme.Colors.accent)
                            .clipShape(Capsule())
                        }
                    }

                    Button {
                        analytics.trackButtonTap("edit_vibes", screen: "edit_profile")
                        showVibeEditor = true
                    } label: {
                        HStack(spacing: TeleportTheme.Spacing.xs) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                            Text("Edit Vibes")
                                .font(TeleportTheme.Typography.caption(14))
                        }
                        .foregroundStyle(TeleportTheme.Colors.accent)
                    }
                    .buttonStyle(.plain)
                }
                .padding(TeleportTheme.Spacing.md)
                .background(TeleportTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium)
                        .strokeBorder(TeleportTheme.Colors.border, lineWidth: 1)
                }
            }
        }
    }

    /// Resolves vibe IDs to full VibeTag objects for display.
    private var selectedVibeDisplayTags: [VibeTag] {
        allVibeTags.filter { selectedVibeIds.contains($0.id) }
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

        // Load saved vibes
        if let savedVibes = coordinator.preferences.selectedVibeTags {
            selectedVibeIds = Set(savedVibes)
        }

        // Fetch all vibe tags for display names/emoji
        Task {
            do {
                allVibeTags = try await coordinator.explorationService.fetchVibeTags()
            } catch {
                print("Failed to load vibe tags for profile: \(error)")
            }
        }
    }

    private func saveChanges() async {
        isSaving = true
        defer { isSaving = false }

        // Update vibes on preferences
        preferences.selectedVibeTags = selectedVibeIds.isEmpty ? nil : Array(selectedVibeIds)

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
            .background(TeleportTheme.Colors.backgroundElevated)
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
