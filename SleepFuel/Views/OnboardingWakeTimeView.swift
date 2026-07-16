import SwiftUI

struct OnboardingWakeTimeView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var sleepDurationHours: Double {
        TimeFormat.sleepDuration(bedtime: state.onboarding.bedtime, wakeTime: state.onboarding.wakeTime)
    }

    var body: some View {
        @Bindable var state = state
        return VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "What time do you wake up?",
                subtitle: "Set your wake time in hours and minutes."
            )

            VStack(spacing: DS.Space.m) {
                HStack(spacing: DS.Space.m) {
                    VStack(spacing: DS.Space.s) {
                        Text("Hour")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(DS.Palette.textTertiary)
                            .textCase(.uppercase)

                        DatePicker(
                            "Time",
                            selection: $state.onboarding.wakeTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .frame(height: 120)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: DS.Space.s) {
                Text("Wake time: \(TimeFormat.clock(state.onboarding.wakeTime))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Text("Sleep window: \(String(format: "%.1f", sleepDurationHours)) hours")
                    .font(.system(size: 14))
                    .foregroundStyle(DS.Palette.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DS.Space.m)
            .dsCard()

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(DS.motion(reduceMotion), value: state.onboarding.wakeTime)
    }
}
