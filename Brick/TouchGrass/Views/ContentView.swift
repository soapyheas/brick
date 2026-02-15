import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var appState: TouchGrassState
    @StateObject private var nfcManager = NFCManager.shared

    @State private var showAppPicker = false
    @State private var showProgramSheet = false
    @State private var showEmergencyConfirm = false
    @State private var programResult: String?
    @State private var emergencyResult: String?
    @State private var pulseAnimation = false

    private let pink = Color(red: 0.85, green: 0.45, blue: 0.55)
    private let lavender = Color(red: 0.62, green: 0.52, blue: 0.82)
    private let peach = Color(red: 0.88, green: 0.65, blue: 0.55)
    private let mint = Color(red: 0.55, green: 0.78, blue: 0.72)
    private let cream = Color(red: 0.97, green: 0.95, blue: 0.92)

    private var backgroundGradient: LinearGradient {
        appState.isLocked
            ? LinearGradient(colors: [lavender.opacity(0.3), pink.opacity(0.2), cream], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [mint.opacity(0.3), peach.opacity(0.2), cream], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()
                    statusView
                    Group {
                        if appState.isLocked, let timestamp = appState.lockTimestamp {
                            TimerView(since: timestamp, accentColor: lavender)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: 50)
                    Spacer()
                    actionButtons
                        .padding(.horizontal, 4)
                        .frame(height: 120)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TouchGrass")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [pink, lavender], startPoint: .leading, endPoint: .trailing)
                        )
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showProgramSheet = true
                        } label: {
                            Label("Program NFC Tag", systemImage: "wave.3.right")
                        }
                    } label: {
                        Image(systemName: "sparkle")
                            .font(.title3)
                            .foregroundStyle(lavender)
                    }
                }
            }
            .sheet(isPresented: $showAppPicker) {
                AppPickerView()
                    .environmentObject(screenTimeManager)
            }
            .alert("Program Tag", isPresented: $showProgramSheet) {
                Button("Let's go!") {
                    nfcManager.programTag { success in
                        programResult = success
                            ? "NFC tag programmed! You're all set."
                            : "Hmm that didn't work. Try again!"
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Hold an NFC tag near your iPhone to program it.")
            }
            .alert("Result", isPresented: .init(
                get: { programResult != nil },
                set: { if !$0 { programResult = nil } }
            )) {
                Button("OK") { programResult = nil }
            } message: {
                Text(programResult ?? "")
            }
            .alert("Emergency Unlock", isPresented: $showEmergencyConfirm) {
                Button("Use Emergency Unlock", role: .destructive) {
                    let success = appState.emergencyUnlock(using: screenTimeManager)
                    if !success {
                        emergencyResult = "No emergency unlocks left. Go find your tag!"
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You have \(appState.emergencyUnlocksRemaining) emergency unlocks left. This cannot be undone. Are you sure?")
            }
            .alert("Emergency Unlock", isPresented: .init(
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
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (appState.isLocked ? lavender : mint).opacity(0.4),
                                .clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseAnimation ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)

                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 130, height: 130)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: appState.isLocked ? [pink, lavender] : [mint, peach],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: (appState.isLocked ? lavender : mint).opacity(0.3), radius: 20, y: 8)

                Image(systemName: appState.isLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: appState.isLocked ? [pink, lavender] : [mint, Color.green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.symbolEffect(.replace))
            }
            .onAppear { pulseAnimation = true }

            Text(appState.isLocked ? "locked in" : "free to scroll")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: appState.isLocked ? [pink, lavender] : [mint, .green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(appState.isLocked
                 ? "your apps are blocked rn. tap your tag to unlock!"
                 : "tap your tag to lock those distracting apps")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("\(appState.emergencyUnlocksRemaining) emergency unlocks left")
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundStyle(lavender.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(lavender.opacity(0.1))
                .clipShape(Capsule())
                .opacity(appState.isLocked ? 1 : 0)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            if !appState.isLocked {
                Button {
                    appState.lock(using: screenTimeManager)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .font(.body.weight(.semibold))
                        Text("touch grass")
                            .font(.system(.headline, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [pink, lavender], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(color: pink.opacity(0.4), radius: 12, y: 6)
                }

                Button {
                    showAppPicker = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "app.badge.checkmark")
                            .font(.body.weight(.semibold))
                        Text("choose apps to block")
                            .font(.system(.headline, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(colors: [peach.opacity(0.5), lavender.opacity(0.5)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: 1.5
                            )
                    )
                }
            }

            if appState.isLocked {
                Button {
                    showEmergencyConfirm = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.subheadline)
                        Text("emergency unlock (\(appState.emergencyUnlocksRemaining) left)")
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                    }
                    .foregroundStyle(appState.emergencyUnlocksRemaining > 0 ? peach : .gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule()
                            .fill(appState.emergencyUnlocksRemaining > 0 ? peach.opacity(0.15) : Color.gray.opacity(0.1))
                    )
                }
                .disabled(appState.emergencyUnlocksRemaining <= 0)
            }
        }
    }
}

struct TimerView: View {
    let since: Date
    var accentColor: Color = .purple
    @State private var elapsed: TimeInterval = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(formattedTime)
            .font(.system(size: 44, weight: .light, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(accentColor.opacity(0.6))
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
        .environmentObject(TouchGrassState.shared)
}
