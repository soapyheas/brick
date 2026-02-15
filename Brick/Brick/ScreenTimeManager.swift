import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published var selectedApps = FamilyActivitySelection() {
        didSet { saveSelection() }
    }
    @Published var isAuthorized = false

    private let store = ManagedSettingsStore()
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private let selectionKey = "selectedApps"

    init() {
        loadSelection()
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await MainActor.run { self.isAuthorized = true }
        } catch {
            print("FamilyControls authorization failed: \(error)")
            await MainActor.run { self.isAuthorized = false }
        }
    }

    func blockApps() {
        let appTokens = selectedApps.applicationTokens
        let categoryTokens = selectedApps.categoryTokens
        store.shield.applications = appTokens.isEmpty ? nil : appTokens
        store.shield.applicationCategories = categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(categoryTokens)
    }

    func unblockApps() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    func clearAll() {
        store.clearAllSettings()
    }

    private func saveSelection() {
        guard let data = try? encoder.encode(selectedApps) else { return }
        UserDefaults.standard.set(data, forKey: selectionKey)
    }

    private func loadSelection() {
        guard let data = UserDefaults.standard.data(forKey: selectionKey),
              let selection = try? decoder.decode(FamilyActivitySelection.self, from: data)
        else { return }
        selectedApps = selection
    }
}
