import SwiftUI

@main
struct ClipApp: App {
    @State private var coordinator = ClipCoordinator()

    var body: some Scene {
        WindowGroup {
            ClipRootView()
                .environment(coordinator)
                .preferredColorScheme(.dark)
        }
    }
}
