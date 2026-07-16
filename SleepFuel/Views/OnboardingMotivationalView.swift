import SwiftUI

struct OnboardingMotivationalView: View {
    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "Sleep earns your screen time",
                subtitle: "Leave your phone alone at night and you get your full time tomorrow. Use it at night and tomorrow's time shrinks."
            )

            Spacer()

            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(DS.Palette.accent)
                .padding(DS.Space.xl)
                .background(DS.Palette.elevated)
                .clipShape(Circle())

            VStack(spacing: DS.Space.s) {
                Text("Full night of sleep")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
                Text("= full screen time tomorrow")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
