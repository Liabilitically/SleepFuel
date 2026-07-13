import SwiftUI

struct OnboardingSymptonsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let symptomKeys = allSymptoms.keys.sorted()

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "Have you felt any of these?",
                subtitle: "This is optional—select what applies."
            )

            VStack(spacing: DS.Space.m) {
                ForEach(symptomKeys, id: \.self) { key in
                    symptomButton(key)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func symptomButton(_ key: String) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                if state.onboarding.symptoms.contains(key) {
                    state.onboarding.symptoms.remove(key)
                } else {
                    state.onboarding.symptoms.insert(key)
                }
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                CheckBox(isOn: state.onboarding.symptoms.contains(key))
                Text(allSymptoms[key] ?? "")
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
