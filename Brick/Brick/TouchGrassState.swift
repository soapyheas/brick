import Foundation
import Combine

class TouchGrassState: ObservableObject {
    static let shared = TouchGrassState()
    static let maxEmergencyUnlocks = 3

    @Published var isLocked: Bool {
        didSet {
            UserDefaults.standard.set(isLocked, forKey: "touchgrassIsLocked")
            lockTimestamp = isLocked ? Date() : nil
        }
    }
    @Published var lockTimestamp: Date?
    @Published var emergencyUnlocksRemaining: Int {
        didSet {
            UserDefaults.standard.set(emergencyUnlocksRemaining, forKey: "emergencyUnlocksRemaining")
        }
    }

    init() {
        self.isLocked = UserDefaults.standard.bool(forKey: "touchgrassIsLocked")

        let stored = UserDefaults.standard.integer(forKey: "emergencyUnlocksRemaining")
        if UserDefaults.standard.object(forKey: "emergencyUnlocksRemaining") == nil {
            self.emergencyUnlocksRemaining = TouchGrassState.maxEmergencyUnlocks
        } else {
            self.emergencyUnlocksRemaining = stored
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
    func emergencyUnlock(using screenTime: ScreenTimeManager) -> Bool {
        guard isLocked else { return false }
        guard emergencyUnlocksRemaining > 0 else { return false }
        emergencyUnlocksRemaining -= 1
        screenTime.unblockApps()
        isLocked = false
        return true
    }

    func resetEmergencyUnlocks() {
        emergencyUnlocksRemaining = TouchGrassState.maxEmergencyUnlocks
    }
}
