import SwiftUI

struct EmergencyUnlockView: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var acknowledged = false

    private var fuelCost: Int {
        state.projectedFuel() - projectedAfterUnlock
    }

    private var projectedAfterUnlock: Int {
        guard let session = state.session else { return 0 }
        var penalties = session.penalties
        penalties.append(Penalty(kind: .emergencyUnlock, minutes: state.emergencyUnlockMinutes))
        let protectedMins = FuelEngine.protectedMinutes(
            scheduled: state.scheduledWindowMinutes,
            penalties: penalties
        )
        return FuelEngine.fuelMinutes(
            protectedMinutes: protectedMins,
            mode: state.fuelMode,
            cap: state.dailyFuelCap
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DS.Palette.textSecondary)
            }
            .padding(.bottom, DS.Space.l)

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(DS.Palette.accent)
                .padding(.bottom, DS.Space.m)

            Text("Unlocking now burns tomorrow's entertainment fuel.")
                .font(DS.Fonts.title)
                .foregroundStyle(DS.Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, DS.Space.s)

            Text("Your apps open for \(state.emergencyUnlockMinutes) minutes. The cost comes out of fuel you've already earned tonight.")
                .font(.system(size: 15))
                .foregroundStyle(DS.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, DS.Space.l)

            VStack(spacing: DS.Space.s) {
                StatusRow(
                    label: "Unlock duration",
                    value: "\(state.emergencyUnlockMinutes) min"
                )
                StatusRow(
                    label: "Protected sleep",
                    value: "−\(state.emergencyUnlockMinutes) min",
                    valueColor: DS.Palette.accent
                )
                StatusRow(
                    label: "Tomorrow's fuel",
                    value: "\(state.projectedFuel()) → \(projectedAfterUnlock) min",
                    valueColor: DS.Palette.accent
                )
            }
            .padding(DS.Space.m)
            .dsCard()
            .padding(.bottom, DS.Space.m)

            Button {
                withAnimation(DS.motion(reduceMotion)) {
                    acknowledged.toggle()
                }
            } label: {
                HStack(spacing: DS.Space.m) {
                    CheckBox(isOn: acknowledged)
                    Text("I understand this costs \(max(fuelCost, 0)) minutes of fuel")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DS.Palette.textPrimary)
                    Spacer()
                }
                .padding(DS.Space.m)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableButtonStyle())
            .dsCard()

            Spacer()

            if acknowledged {
                HoldToConfirmButton(title: "Hold to unlock") {
                    state.applyEmergencyUnlock()
                    dismiss()
                }
                .transition(.opacity)
            } else {
                Text("Confirm above to enable unlock")
                    .font(.system(size: 13))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
        }
        .padding(DS.Space.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DS.Palette.obsidian.ignoresSafeArea())
        .animation(DS.motion(reduceMotion), value: acknowledged)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
