import SwiftUI

// MARK: - Clip Root View

struct ClipRootView: View {
    @Environment(ClipCoordinator.self) private var coordinator

    var body: some View {
        Group {
            switch coordinator.currentScreen {
            case .preferences:
                ClipPreferencesView()
            case .generating:
                ClipGeneratingView()
            case .results:
                ClipResultsView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen.hashValue)
        .task {
            await coordinator.cityService.fetchAllCities()
        }
    }
}
