import SwiftUI

struct OnboardingGoalsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let goalKeys = allGoals.keys.sorted()

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "What's your goal?",
                subtitle: "Choose at least one."
            )

            VStack(spacing: DS.Space.m) {
                ForEach(goalKeys, id: \.self) { key in
                    goalButton(key)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func goalButton(_ key: String) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                if state.onboarding.goals.contains(key) {
                    state.onboarding.goals.remove(key)
                } else {
                    state.onboarding.goals.insert(key)
                }
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                CheckBox(isOn: state.onboarding.goals.contains(key))
                Text(allGoals[key] ?? "")
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
