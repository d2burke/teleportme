import SwiftUI
import MapKit

// MARK: - Filter State

private enum CityMapFilter: String, CaseIterable {
    case all = "All"
    case explored = "Explored"
    case saved = "Saved"
}

// MARK: - City Map View

struct CityMapView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var screenEnteredAt = Date()
    private let analytics = AnalyticsService.shared

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 80)
        )
    )
    @State private var selectedCity: City?
    @State private var activeFilter: CityMapFilter = .all

    // MARK: - Computed Properties

    /// All unique city IDs across all explorations (union of all results).
    private var exploredCityIds: Set<String> {
        let fromExplorations = coordinator.explorationService.explorations
            .flatMap { $0.results.map(\.cityId) }
        let fromCurrentReport = coordinator.reportService.currentReport?.matches.map(\.cityId) ?? []
        return Set(fromExplorations + fromCurrentReport)
    }

    private var matchedCityIds: Set<String> {
        exploredCityIds
    }

    private var filteredCities: [City] {
        switch activeFilter {
        case .all:
            return coordinator.cityService.allCities
        case .explored:
            return coordinator.cityService.allCities.filter { exploredCityIds.contains($0.id) }
        case .saved:
            return coordinator.cityService.allCities.filter { coordinator.savedCitiesService.isSaved(cityId: $0.id) }
        }
    }

    private func matchForCity(_ cityId: String) -> CityMatch? {
        coordinator.reportService.currentReport?.matches.first { $0.cityId == cityId }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Full-screen map
                Map(position: $cameraPosition) {
                    ForEach(filteredCities) { city in
                        Annotation(
                            city.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: city.latitude,
                                longitude: city.longitude
                            )
                        ) {
                            CityAnnotationMarker(
                                city: city,
                                isMatched: matchedCityIds.contains(city.id),
                                isSaved: coordinator.savedCitiesService.isSaved(cityId: city.id),
                                isSelected: selectedCity?.id == city.id
                            )
                            .onTapGesture {
                                analytics.trackButtonTap("city_pin", screen: "map", properties: ["city_id": city.id])
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedCity = city
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea(edges: .all)

                // Filter bar overlay
                filterBar
                    .padding(.top, TeleportTheme.Spacing.sm)

                // Bottom card overlay
                if let city = selectedCity {
                    VStack {
                        Spacer()
                        CityMapCard(
                            city: city,
                            match: matchForCity(city.id),
                            isSaved: coordinator.savedCitiesService.isSaved(cityId: city.id),
                            onSaveToggle: {
                                Task {
                                    await coordinator.savedCitiesService.toggleSave(cityId: city.id)
                                }
                            },
                            onDismiss: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedCity = nil
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, TeleportTheme.Spacing.md)
                        .padding(.bottom, TeleportTheme.Spacing.md)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: City.self) { city in
                CityDetailView(city: city)
            }
            .task {
                await coordinator.cityService.fetchAllCities()
                await coordinator.savedCitiesService.loadSavedCities()
            }
        }
        .tint(TeleportTheme.Colors.textPrimary)
        .onAppear {
            screenEnteredAt = Date()
            analytics.trackScreenView("map")
        }
        .onDisappear {
            let ms = Int(Date().timeIntervalSince(screenEnteredAt) * 1000)
            analytics.trackScreenExit("map", durationMs: ms, exitType: "tab_switch")
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: TeleportTheme.Spacing.sm) {
            ForEach(CityMapFilter.allCases, id: \.self) { filter in
                TrendingChip(
                    title: filter.rawValue,
                    isSelected: activeFilter == filter
                ) {
                    analytics.track("map_filter_changed", screen: "map", properties: [
                        "filter": filter.rawValue.lowercased(),
                        "previous_filter": activeFilter.rawValue.lowercased()
                    ])
                    withAnimation(.easeInOut(duration: 0.2)) {
                        activeFilter = filter
                        selectedCity = nil
                    }
                }
            }
        }
        .padding(.horizontal, TeleportTheme.Spacing.md)
        .padding(.vertical, TeleportTheme.Spacing.sm)
        .background(
            Capsule()
                .fill(TeleportTheme.Colors.background.opacity(0.7))
                .overlay {
                    Capsule()
                        .strokeBorder(TeleportTheme.Colors.border.opacity(0.5), lineWidth: 1)
                }
        )
    }
}

// MARK: - City Annotation Marker

private struct CityAnnotationMarker: View {
    let city: City
    let isMatched: Bool
    let isSaved: Bool
    let isSelected: Bool

    private var markerColor: Color {
        isMatched ? TeleportTheme.Colors.accent : .white
    }

    var body: some View {
        ZStack {
            // Outer glow for selected state
            if isSelected {
                Circle()
                    .fill(markerColor.opacity(0.3))
                    .frame(width: 32, height: 32)
            }

            // Main circle
            Circle()
                .fill(markerColor)
                .frame(width: isSaved ? 20 : 14, height: isSaved ? 20 : 14)
                .overlay {
                    if isSaved {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(TeleportTheme.Colors.background)
                    }
                }
                .shadow(color: markerColor.opacity(0.5), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - City Map Card (bottom overlay)

private struct CityMapCard: View {
    let city: City
    let match: CityMatch?
    let isSaved: Bool
    let onSaveToggle: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        CardView(padding: 0) {
            VStack(spacing: 0) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(TeleportTheme.Colors.textTertiary)
                    .frame(width: 36, height: 4)
                    .padding(.top, TeleportTheme.Spacing.sm)

                HStack(alignment: .top, spacing: TeleportTheme.Spacing.md) {
                    // City image thumbnail
                    AsyncImage(url: URL(string: city.imageUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(TeleportTheme.Colors.surfaceElevated)
                                .overlay {
                                    Image(systemName: "building.2")
                                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                }
                        }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.small))

                    // City info
                    VStack(alignment: .leading, spacing: TeleportTheme.Spacing.xs) {
                        Text(city.name)
                            .font(TeleportTheme.Typography.cardTitle(20))
                            .foregroundStyle(TeleportTheme.Colors.textPrimary)

                        Text(city.country)
                            .font(TeleportTheme.Typography.body(14))
                            .foregroundStyle(TeleportTheme.Colors.textSecondary)

                        HStack(spacing: TeleportTheme.Spacing.sm) {
                            // Teleport score
                            if let score = city.teleportCityScore {
                                HStack(spacing: TeleportTheme.Spacing.xs) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(TeleportTheme.Colors.accent)
                                    Text(String(format: "%.1f", score))
                                        .font(TeleportTheme.Typography.caption(13))
                                        .foregroundStyle(TeleportTheme.Colors.textPrimary)
                                    Text("/ 100")
                                        .font(TeleportTheme.Typography.caption(11))
                                        .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                }
                            }

                            // Match badge
                            if let match {
                                Text("\(match.matchPercent)% match")
                                    .font(TeleportTheme.Typography.sectionHeader(11))
                                    .foregroundStyle(TeleportTheme.Colors.background)
                                    .padding(.horizontal, TeleportTheme.Spacing.sm)
                                    .padding(.vertical, 3)
                                    .background(TeleportTheme.Colors.accent)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    Spacer()

                    // Save button
                    VStack(spacing: TeleportTheme.Spacing.sm) {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(TeleportTheme.Colors.textTertiary)
                                .frame(width: 28, height: 28)
                                .background(TeleportTheme.Colors.surfaceElevated)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)

                        Button(action: onSaveToggle) {
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(
                                    isSaved
                                        ? TeleportTheme.Colors.accent
                                        : TeleportTheme.Colors.textSecondary
                                )
                                .frame(width: 36, height: 36)
                                .background(TeleportTheme.Colors.surfaceElevated)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(TeleportTheme.Spacing.md)

                // View Details button
                NavigationLink(value: city) {
                    HStack(spacing: TeleportTheme.Spacing.sm) {
                        Text("View Details")
                            .font(TeleportTheme.Typography.cardTitle(14))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(TeleportTheme.Colors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TeleportTheme.Spacing.sm)
                    .background(TeleportTheme.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: TeleportTheme.Radius.medium))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, TeleportTheme.Spacing.md)
                .padding(.bottom, TeleportTheme.Spacing.md)
            }
        }
    }
}

// MARK: - Preview

#Preview("City Map") {
    PreviewContainer(coordinator: PreviewHelpers.makeCoordinatorWithReport()) {
        CityMapView()
    }
}
