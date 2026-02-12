import SwiftUI

// MARK: - Saved Cities View

struct SavedView: View {
    @Environment(AppCoordinator.self) private var coordinator

    private var savedCitiesService: SavedCitiesService {
        coordinator.savedCitiesService
    }

    private var cityService: CityService {
        coordinator.cityService
    }

    /// Resolves a SavedCity to its full City model by matching cityId.
    private func city(for savedCity: SavedCity) -> City? {
        cityService.allCities.first { $0.id == savedCity.cityId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TeleportTheme.Colors.background
                    .ignoresSafeArea()

                if savedCitiesService.savedCities.isEmpty && !savedCitiesService.isLoading {
                    emptyStateView
                } else {
                    savedCitiesList
                }
            }
            .navigationTitle("Saved Cities")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            await savedCitiesService.loadSavedCities()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: TeleportTheme.Spacing.md) {
            Image(systemName: "heart")
                .font(.system(size: 56))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)

            Text("No saved cities yet")
                .font(TeleportTheme.Typography.title(24))
                .foregroundStyle(TeleportTheme.Colors.textPrimary)

            Text("Tap the heart on any city to save it here")
                .font(TeleportTheme.Typography.body())
                .foregroundStyle(TeleportTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, TeleportTheme.Spacing.xl)
    }

    // MARK: - Saved Cities List

    private var savedCitiesList: some View {
        List {
            ForEach(savedCitiesService.savedCities) { savedCity in
                if let city = city(for: savedCity) {
                    savedCityRow(city: city, savedCity: savedCity)
                        .listRowBackground(TeleportTheme.Colors.background)
                        .listRowSeparatorTint(TeleportTheme.Colors.border)
                        .listRowInsets(EdgeInsets(
                            top: TeleportTheme.Spacing.sm,
                            leading: TeleportTheme.Spacing.md,
                            bottom: TeleportTheme.Spacing.sm,
                            trailing: TeleportTheme.Spacing.md
                        ))
                }
            }
            .onDelete { indexSet in
                deleteSavedCities(at: indexSet)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await savedCitiesService.loadSavedCities()
        }
    }

    // MARK: - City Row

    private func savedCityRow(city: City, savedCity: SavedCity) -> some View {
        CardView {
            HStack(spacing: TeleportTheme.Spacing.md) {
                // City image
                AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        imagePlaceholder
                    default:
                        ProgressView()
                            .tint(TeleportTheme.Colors.accent)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(TeleportTheme.Colors.surfaceElevated)
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                // City info
                VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                    Text(city.name)
                        .font(TeleportTheme.Typography.cardTitle())
                        .foregroundStyle(TeleportTheme.Colors.textPrimary)

                    Text(city.country)
                        .font(TeleportTheme.Typography.body(14))
                        .foregroundStyle(TeleportTheme.Colors.textSecondary)
                }

                Spacer()

                // Heart button to unsave
                Button {
                    Task {
                        await savedCitiesService.toggleSave(cityId: city.id)
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(TeleportTheme.Colors.accent)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Image Placeholder

    private var imagePlaceholder: some View {
        ZStack {
            TeleportTheme.Colors.surfaceElevated
            Image(systemName: "building.2")
                .font(.system(size: 20))
                .foregroundStyle(TeleportTheme.Colors.textTertiary)
        }
    }

    // MARK: - Delete

    private func deleteSavedCities(at offsets: IndexSet) {
        let citiesToRemove = offsets.compactMap { index -> String? in
            guard index < savedCitiesService.savedCities.count else { return nil }
            return savedCitiesService.savedCities[index].cityId
        }

        for cityId in citiesToRemove {
            Task {
                await savedCitiesService.unsave(cityId: cityId)
            }
        }
    }
}

// MARK: - Preview

#Preview("Saved Cities") {
    PreviewContainer {
        SavedView()
    }
}
