import SwiftUI

@main
struct SleepFuelApp: App {
    @State private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                appState.appBecameActive()
            case .inactive, .background:
                appState.appResignedActive()
            @unknown default:
                break
            }
        }
    }
}
