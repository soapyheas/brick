import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if screenTimeManager.isAuthorized {
                    FamilyActivityPicker(selection: $screenTimeManager.selectedApps)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)

                        Text("Screen Time permission required")
                            .font(.headline)

                        Text("Brick needs Screen Time access to block apps. Tap below to grant permission.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Grant Permission") {
                            Task {
                                await screenTimeManager.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                }
            }
        }
    }
}

#Preview {
    AppPickerView()
        .environmentObject(ScreenTimeManager.shared)
}
