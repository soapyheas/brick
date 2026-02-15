import SwiftUI
import FamilyControls

@main
struct TouchGrassApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @StateObject private var appState = TouchGrassState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(screenTimeManager)
                .environmentObject(appState)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }

    private func handleURL(_ url: URL) {
        guard url.host == "toggle" || url.path.contains("toggle") else { return }
        Task {
            await appState.toggle(using: screenTimeManager)
        }
    }
}
