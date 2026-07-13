import SwiftUI

struct OnboardingGoodHandsView: View {
    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "You're in good hands",
                subtitle: "Thousands of people sleep better with SleepFuel."
            )

            Spacer()

            Image(systemName: "handshake.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(DS.Palette.accent)
                .padding(DS.Space.xl)
                .background(DS.Palette.elevated)
                .clipShape(Circle())

            VStack(spacing: DS.Space.s) {
                Text("Thousands of people sleep better")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
                Text("with SleepFuel")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
