import SwiftUI

// MARK: - Clip Root View

struct ClipRootView: View {
    @Environment(ClipCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coord = coordinator

        Group {
            switch coordinator.currentScreen {
            case .startType:
                ClipStartTypeView()
            case .tripVibes:
                TripVibesView(
                    signalWeights: $coord.signalWeights,
                    onContinue: {
                        coordinator.advanceFromTripVibes()
                    },
                    onBack: {
                        coordinator.goBackFromTripVibes()
                    }
                )
            case .constraints:
                ConstraintsView(
                    constraints: $coord.tripConstraints,
                    onContinue: {
                        coordinator.advanceFromConstraints()
                    },
                    onBack: {
                        coordinator.goBackFromConstraints()
                    }
                )
            case .generating:
                ClipGeneratingView()
            case .results:
                ClipResultsView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen)
        .task {
            await coordinator.cityService.fetchAllCities()
        }
    }
}
