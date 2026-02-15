import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) private var dismiss

    private let pink = Color(red: 1.0, green: 0.42, blue: 0.62)
    private let lavender = Color(red: 0.72, green: 0.53, blue: 0.98)
    private let peach = Color(red: 1.0, green: 0.70, blue: 0.60)

    var body: some View {
        NavigationStack {
            VStack {
                if screenTimeManager.isAuthorized {
                    FamilyActivityPicker(selection: $screenTimeManager.selectedApps)
                } else {
                    VStack(spacing: 20) {
                        Spacer()

                        Image(systemName: "lock.trianglebadge.exclamationmark")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(colors: [peach, pink], startPoint: .top, endPoint: .bottom)
                            )

                        Text("one sec babe")
                            .font(.system(.title2, design: .rounded).weight(.heavy))

                        Text("TouchGrass needs screen time access to block your apps. tap below to grant permission!")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Button {
                            Task {
                                await screenTimeManager.requestAuthorization()
                            }
                        } label: {
                            Text("grant permission")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 36)
                                .background(
                                    LinearGradient(colors: [pink, lavender], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(Capsule())
                                .shadow(color: pink.opacity(0.3), radius: 10, y: 5)
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("pick your apps")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [pink, lavender], startPoint: .leading, endPoint: .trailing)
                        )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("done")
                            .font(.system(.body, design: .rounded).weight(.bold))
                            .foregroundStyle(lavender)
                    }
                }
            }
        }
    }
}

#Preview {
    AppPickerView()
        .environmentObject(ScreenTimeManager.shared)
}
