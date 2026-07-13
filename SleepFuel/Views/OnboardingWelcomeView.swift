import SwiftUI

struct OnboardingWelcomeView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let options = allHeardAboutOptions

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "How did you hear about SleepFuel?",
                subtitle: "We'd love to know."
            )

            VStack(spacing: DS.Space.m) {
                ForEach(options, id: \.self) { option in
                    optionButton(option)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func optionButton(_ option: String) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                state.onboarding.heardAbout = option
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                CheckBox(isOn: state.onboarding.heardAbout == option)
                Text(option)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
