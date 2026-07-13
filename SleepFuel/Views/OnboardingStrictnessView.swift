import SwiftUI

struct OnboardingStrictnessView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let options = BlockingStrictness.allCases

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "How strict should blocking be?",
                subtitle: "Choose one level."
            )

            VStack(spacing: DS.Space.m) {
                ForEach(options, id: \.id) { option in
                    strictnessButton(option)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func strictnessButton(_ option: BlockingStrictness) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                state.onboarding.blockingStrictness = option.rawValue
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                ZStack {
                    Circle()
                        .fill(
                            state.onboarding.blockingStrictness == option.rawValue
                                ? DS.Palette.accent
                                : DS.Palette.elevated
                        )
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    state.onboarding.blockingStrictness == option.rawValue
                                        ? DS.Palette.accent
                                        : DS.Palette.border,
                                    lineWidth: 1
                                )
                        )

                    if state.onboarding.blockingStrictness == option.rawValue {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }

                VStack(alignment: .leading, spacing: DS.Space.s) {
                    Text(option.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DS.Palette.textPrimary)
                    Text(option.detail)
                        .font(.system(size: 13))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
