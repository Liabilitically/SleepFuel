import SwiftUI
import Combine

struct ActiveSleepSessionView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var now = Date()
    @State private var showEmergencyUnlock = false
    @State private var pulse = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, DS.Space.l)
                .padding(.top, DS.Space.m)

            Spacer()

            countdown

            Spacer()

            VStack(spacing: DS.Space.m) {
                statusCard
                SecondaryButton(title: "Emergency unlock") {
                    showEmergencyUnlock = true
                }
                prototypeControls
            }
            .padding(DS.Space.l)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Palette.obsidian.ignoresSafeArea())
        .onReceive(ticker) { now = $0 }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .sheet(isPresented: $showEmergencyUnlock) {
            EmergencyUnlockView()
        }
        .interactiveDismissDisabled()
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: DS.Space.s) {
            Circle()
                .fill(DS.Palette.accent)
                .frame(width: 8, height: 8)
                .opacity(pulse ? 0.4 : 1)

            Text("Fuel generating")
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(DS.Palette.textSecondary)

            Spacer()

            TagView(text: "Active", color: DS.Palette.accent)
        }
    }

    // MARK: - Countdown

    private var countdown: some View {
        let remaining = max(0, state.scheduledWindowMinutes - state.sessionElapsedMinutes(now: now))

        return VStack(spacing: DS.Space.m) {
            Text(TimeFormat.hoursMinutes(remaining))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(DS.Palette.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(DS.motion(reduceMotion), value: remaining)

            Text("until \(TimeFormat.clock(state.wakeTime))")
                .font(.system(size: 15))
                .foregroundStyle(DS.Palette.textTertiary)

            HStack(spacing: DS.Space.l) {
                VStack(spacing: 2) {
                    Text("\(state.fuelGeneratedSoFar(now: now))")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(DS.Palette.accent)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(DS.motion(reduceMotion), value: state.fuelGeneratedSoFar(now: now))
                    Text("min earned")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Rectangle()
                    .fill(DS.Palette.border)
                    .frame(width: DS.hairline, height: 36)

                VStack(spacing: 2) {
                    Text("\(state.projectedFuel())")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(DS.Palette.textSecondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(DS.motion(reduceMotion), value: state.projectedFuel())
                    Text("projected")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                }
            }
            .padding(.top, DS.Space.s)
        }
    }

    // MARK: - Status card

    private var statusCard: some View {
        VStack(spacing: DS.Space.s) {
            StatusRow(
                label: "App shield",
                value: "\(state.selectedTargets.count) shielded",
                valueColor: DS.Palette.textPrimary
            )
            StatusRow(
                label: "Anchor",
                value: anchorStatus.0,
                valueColor: anchorStatus.1
            )
            if state.sessionPenaltyTotal() > 0 {
                StatusRow(
                    label: "Penalties tonight",
                    value: "−\(state.sessionPenaltyTotal()) min",
                    valueColor: DS.Palette.accent
                )
            }
        }
        .padding(DS.Space.m)
        .dsCard()
    }

    private var anchorStatus: (String, Color) {
        guard state.anchorModeEnabled else { return ("Off", DS.Palette.textTertiary) }
        if state.session?.anchorEngaged == true {
            return ("Docked", DS.Palette.success)
        }
        return ("Not scanned", DS.Palette.accent)
    }

    // MARK: - Prototype controls

    private var prototypeControls: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack {
                SectionHeader(title: "Prototype controls")
                TagView(text: "Sim")
            }

            HStack(spacing: DS.Space.s) {
                simButton("+1 hour") {
                    state.simulateHourPassed()
                }
                simButton("Unlock") {
                    showEmergencyUnlock = true
                }
            }
            HStack(spacing: DS.Space.s) {
                simButton("Fail night") {
                    state.failNight()
                }
                simButton("Complete night") {
                    state.completeNight()
                }
            }
        }
        .padding(DS.Space.m)
        .dsCard(elevated: true)
    }

    private func simButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DS.Palette.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(DS.Palette.surface)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                        .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
                )
        }
        .buttonStyle(PressableButtonStyle())
    }
}
