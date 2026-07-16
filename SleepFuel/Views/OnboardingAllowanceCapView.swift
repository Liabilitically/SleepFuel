import SwiftUI

struct OnboardingAllowanceCapView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let minCap = 30
    private let maxCap = 300

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "How much phone time do you want each day?",
                subtitle: "Sleep the full night and you get all of it."
            )

            VStack(spacing: DS.Space.l) {
                Text("\(state.onboarding.allowanceCap)")
                    .font(DS.Fonts.display)
                    .foregroundStyle(DS.Palette.accent)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Text("minutes")
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Palette.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(DS.Space.l)
            .dsCard()

            VStack(spacing: DS.Space.m) {
                Slider(
                    value: Binding(
                        get: { Double(state.onboarding.allowanceCap) },
                        set: { state.onboarding.allowanceCap = Int($0) }
                    ),
                    in: Double(minCap)...Double(maxCap),
                    step: 10
                )
                .tint(DS.Palette.accent)

                HStack(spacing: DS.Space.m) {
                    Text("\(minCap)m")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                    Spacer()
                    Text("\(maxCap)m")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                }
            }
            .padding(DS.Space.m)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(DS.motion(reduceMotion), value: state.onboarding.allowanceCap)
    }
}
