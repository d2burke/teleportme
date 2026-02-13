import SwiftUI

// MARK: - Exploration City Picker Step

struct ExplorationCityPickerStepView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Binding var selectedCityId: String?
    @Binding var selectedCityName: String?
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var searchText = ""
    @State private var searchResults: [City] = []
    @State private var isSearching = false

    var body: some View {
        ScrollView {
            VStack(spacing: TeleportTheme.Spacing.xl) {
                // Header
                VStack(spacing: TeleportTheme.Spacing.sm) {
                    Text("Pick a baseline city")
                        .font(TeleportTheme.Typography.title(26))
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("We'll find cities similar to this one, tuned to your preferences.")
                        .font(TeleportTheme.Typography.body(15))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TeleportTheme.Spacing.lg)
                }
                .padding(.top, TeleportTheme.Spacing.md)

                // Search bar
                HStack(spacing: TeleportTheme.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                    TextField("Search for a city", text: $searchText)
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

                // Selected city indicator
                if let cityName = selectedCityName {
                    HStack(spacing: TeleportTheme.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(TeleportTheme.Colors.accent)
                        Text(cityName)
                            .font(TeleportTheme.Typography.cardTitle())
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)
                        Spacer()
                        Button {
                            selectedCityId = nil
                            selectedCityName = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                        }
                    }
                    .padding(TeleportTheme.Spacing.md)
                    .background(TeleportTheme.Colors.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                }

                // Search results
                if !searchResults.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(searchResults.prefix(8)) { city in
                            CitySearchRow(city: city) {
                                selectedCityId = city.id
                                selectedCityName = city.name
                                searchText = ""
                                searchResults = []
                            }
                        }
                    }
                    .padding(.horizontal, TeleportTheme.Spacing.lg)
                } else if searchText.isEmpty && selectedCityId == nil {
                    // Trending cities
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.sm) {
                        Text("TRENDING NOW")
                            .font(TeleportTheme.Typography.sectionHeader())
                            .foregroundStyle(TeleportTheme.Colors.textTertiary)
                            .tracking(1.5)
                            .padding(.horizontal, TeleportTheme.Spacing.lg)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: TeleportTheme.Spacing.sm) {
                                ForEach(coordinator.cityService.trendingCities) { city in
                                    TrendingChip(title: city.name) {
                                        selectedCityId = city.id
                                        selectedCityName = city.name
                                    }
                                }
                            }
                            .padding(.horizontal, TeleportTheme.Spacing.lg)
                        }
                    }
                }

                if !searchText.isEmpty && searchResults.isEmpty && !isSearching {
                    Text("No cities found for \"\(searchText)\"")
                        .font(TeleportTheme.Typography.body())
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }
            }
            .padding(.bottom, 100)
        }
        .background(TeleportTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Skip") { onSkip() }
                    .font(TeleportTheme.Typography.body(14))
                    .foregroundStyle(TeleportTheme.Colors.textSecondary)
            }
        }
        .overlay(alignment: .bottom) {
            TeleportButton(
                title: selectedCityId != nil ? "Continue" : "Skip — No Baseline",
                icon: "arrow.right"
            ) {
                if selectedCityId != nil {
                    onContinue()
                } else {
                    onSkip()
                }
            }
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
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        searchResults = await coordinator.cityService.searchCities(query: query)
        isSearching = false
    }
}
