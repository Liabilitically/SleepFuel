import SwiftUI

struct OnboardingBedtimeView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        @Bindable var state = state
        return VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "What time do you go to bed?",
                subtitle: "Set your bedtime in hours and minutes."
            )

            VStack(spacing: DS.Space.m) {
                HStack(spacing: DS.Space.m) {
                    VStack(spacing: DS.Space.s) {
                        Text("Hour")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(DS.Palette.textTertiary)
                            .textCase(.uppercase)

                        DatePicker(
                            "Hour",
                            selection: $state.onboarding.bedtime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .frame(height: 120)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: DS.Space.s) {
                Text("Selected time: \(TimeFormat.clock(state.onboarding.bedtime))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(DS.Space.m)
            .dsCard()

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(DS.motion(reduceMotion), value: state.onboarding.bedtime)
    }
}
