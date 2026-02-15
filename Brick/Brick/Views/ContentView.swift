import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var brickState: BrickState
    @StateObject private var nfcManager = NFCManager.shared

    @State private var showAppPicker = false
    @State private var showProgramSheet = false
    @State private var showEmergencyConfirm = false
    @State private var programResult: String?
    @State private var emergencyResult: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                statusView
                if brickState.isLocked, let timestamp = brickState.lockTimestamp {
                    TimerView(since: timestamp)
                }
                Spacer()
                actionButtons
                Spacer()
            }
            .padding()
            .navigationTitle("Brick")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Program NFC Tag") { showProgramSheet = true }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showAppPicker) {
                AppPickerView()
                    .environmentObject(screenTimeManager)
            }
            .alert("Program Brick", isPresented: $showProgramSheet) {
                Button("Start") {
                    nfcManager.programBrick { success in
                        programResult = success
                            ? "NFC tag programmed! It's now a Brick."
                            : "Failed to program tag. Try again."
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Hold an NFC tag near your iPhone to program it as a Brick.")
            }
            .alert("Result", isPresented: .init(
                get: { programResult != nil },
                set: { if !$0 { programResult = nil } }
            )) {
                Button("OK") { programResult = nil }
            } message: {
                Text(programResult ?? "")
            }
            .alert("Emergency Unbrick", isPresented: $showEmergencyConfirm) {
                Button("Use Emergency Unbrick", role: .destructive) {
                    let success = brickState.emergencyUnbrick(using: screenTimeManager)
                    if !success {
                        emergencyResult = "No emergency unbricks remaining. You must tap your Brick to unlock."
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You have \(brickState.emergencyUnbricksRemaining) emergency unbricks left. This cannot be undone. Are you sure?")
            }
            .alert("Emergency Unbrick", isPresented: .init(
                get: { emergencyResult != nil },
                set: { if !$0 { emergencyResult = nil } }
            )) {
                Button("OK") { emergencyResult = nil }
            } message: {
                Text(emergencyResult ?? "")
            }
            .task {
                if !screenTimeManager.isAuthorized {
                    await screenTimeManager.requestAuthorization()
                }
            }
        }
    }

    private var statusView: some View {
        VStack(spacing: 16) {
            Image(systemName: brickState.isLocked ? "lock.fill" : "lock.open.fill")
                .font(.system(size: 72))
                .foregroundStyle(brickState.isLocked ? .red : .green)
                .contentTransition(.symbolEffect(.replace))

            Text(brickState.isLocked ? "Bricked" : "Unbricked")
                .font(.largeTitle.bold())

            Text(brickState.isLocked
                 ? "Your selected apps are blocked. Tap your Brick to unlock."
                 : "Tap your Brick to lock down distracting apps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if brickState.isLocked {
                Text("\(brickState.emergencyUnbricksRemaining) emergency unbricks remaining")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            if !brickState.isLocked {
                Button {
                    brickState.lock(using: screenTimeManager)
                } label: {
                    Label("Brick My Phone", systemImage: "lock.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button {
                    showAppPicker = true
                } label: {
                    Label("Choose Apps to Block", systemImage: "app.badge.checkmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            if brickState.isLocked {
                Button {
                    showEmergencyConfirm = true
                } label: {
                    Label(
                        "Emergency Unbrick (\(brickState.emergencyUnbricksRemaining) left)",
                        systemImage: "exclamationmark.triangle"
                    )
                        .font(.subheadline)
                        .foregroundStyle(brickState.emergencyUnbricksRemaining > 0 ? .orange : .gray)
                }
                .disabled(brickState.emergencyUnbricksRemaining <= 0)
            }
        }
    }
}

struct TimerView: View {
    let since: Date
    @State private var elapsed: TimeInterval = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(formattedTime)
            .font(.system(size: 48, weight: .light, design: .monospaced))
            .foregroundStyle(.secondary)
            .onReceive(timer) { _ in
                elapsed = Date().timeIntervalSince(since)
            }
            .onAppear {
                elapsed = Date().timeIntervalSince(since)
            }
    }

    private var formattedTime: String {
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ContentView()
        .environmentObject(ScreenTimeManager.shared)
        .environmentObject(BrickState.shared)
}
