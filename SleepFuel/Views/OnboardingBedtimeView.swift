import SwiftUI

struct OnboardingBedtimeView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state
        return VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "What time do you go to bed?",
                subtitle: "Pick the time you want to fall asleep."
            )

            DatePicker(
                "",
                selection: $state.onboarding.bedtime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
