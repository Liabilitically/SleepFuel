import SwiftUI

struct OnboardingWakeTimeView: View {
    @Environment(AppState.self) private var state

    private var sleepDurationHours: Double {
        TimeFormat.sleepDuration(bedtime: state.onboarding.bedtime, wakeTime: state.onboarding.wakeTime)
    }

    var body: some View {
        @Bindable var state = state
        return VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "What time do you wake up?",
                subtitle: "Pick the time you want to get up."
            )

            DatePicker(
                "",
                selection: $state.onboarding.wakeTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)

            Text("Sleep window: \(String(format: "%.1f", sleepDurationHours)) hours")
                .font(.system(size: 14))
                .foregroundStyle(DS.Palette.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(DS.Space.m)
                .dsCard()

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
