import SwiftUI
import FamilyControls

@main
struct BrickApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @StateObject private var brickState = BrickState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(screenTimeManager)
                .environmentObject(brickState)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }

    private func handleURL(_ url: URL) {
        guard url.host == "toggle" || url.path.contains("toggle") else { return }
        Task {
            await brickState.toggle(using: screenTimeManager)
        }
    }
}
