import Foundation
import Combine

class BrickState: ObservableObject {
    static let shared = BrickState()
    static let maxEmergencyUnbricks = 5

    @Published var isLocked: Bool {
        didSet {
            UserDefaults.standard.set(isLocked, forKey: "brickIsLocked")
            lockTimestamp = isLocked ? Date() : nil
        }
    }
    @Published var lockTimestamp: Date?
    @Published var emergencyUnbricksRemaining: Int {
        didSet {
            UserDefaults.standard.set(emergencyUnbricksRemaining, forKey: "emergencyUnbricksRemaining")
        }
    }

    init() {
        self.isLocked = UserDefaults.standard.bool(forKey: "brickIsLocked")

        let stored = UserDefaults.standard.integer(forKey: "emergencyUnbricksRemaining")
        if UserDefaults.standard.object(forKey: "emergencyUnbricksRemaining") == nil {
            self.emergencyUnbricksRemaining = BrickState.maxEmergencyUnbricks
        } else {
            self.emergencyUnbricksRemaining = stored
        }

        if isLocked {
            self.lockTimestamp = Date()
        }
    }

    @MainActor
    func toggle(using screenTime: ScreenTimeManager) async {
        if isLocked {
            screenTime.unblockApps()
            isLocked = false
        } else {
            screenTime.blockApps()
            isLocked = true
        }
    }

    @MainActor
    func lock(using screenTime: ScreenTimeManager) {
        guard !isLocked else { return }
        screenTime.blockApps()
        isLocked = true
    }

    @MainActor
    func unlock(using screenTime: ScreenTimeManager) {
        guard isLocked else { return }
        screenTime.unblockApps()
        isLocked = false
    }

    @MainActor
    func emergencyUnbrick(using screenTime: ScreenTimeManager) -> Bool {
        guard isLocked else { return false }
        guard emergencyUnbricksRemaining > 0 else { return false }
        emergencyUnbricksRemaining -= 1
        screenTime.unblockApps()
        isLocked = false
        return true
    }

    func resetEmergencyUnbricks() {
        emergencyUnbricksRemaining = BrickState.maxEmergencyUnbricks
    }
}
