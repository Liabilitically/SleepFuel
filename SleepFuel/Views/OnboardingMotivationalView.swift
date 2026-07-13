import SwiftUI

struct OnboardingMotivationalView: View {
    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "Good sleep = more focus tomorrow",
                subtitle: "Based on sleep data, 8 hours = 100 minutes of entertainment tomorrow."
            )

            Spacer()

            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(DS.Palette.accent)
                .padding(DS.Space.xl)
                .background(DS.Palette.elevated)
                .clipShape(Circle())

            VStack(spacing: DS.Space.s) {
                Text("8 hours of sleep")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
                Text("= 100 minutes of entertainment")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
