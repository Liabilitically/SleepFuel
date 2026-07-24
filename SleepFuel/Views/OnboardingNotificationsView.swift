import SwiftUI

struct OnboardingNotificationsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "Turn on notifications?",
                subtitle: "We remind you 5 minutes before bed and show your time each morning."
            )

            Spacer()

            Image(systemName: "bell.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(DS.Palette.accent)
                .padding(DS.Space.xl)
                .background(DS.Palette.elevated)
                .clipShape(Circle())

            Spacer()

            VStack(spacing: DS.Space.m) {
                PrimaryButton(title: "Allow") {
                    Task {
                        let granted = await NotificationManager.requestAuthorization()
                        withAnimation(DS.motion(reduceMotion)) {
                            state.onboarding.notificationsAllowed = granted
                            state.advanceOnboarding()
                        }
                    }
                }

                SecondaryButton(title: "Don't Allow") {
                    withAnimation(DS.motion(reduceMotion)) {
                        state.onboarding.notificationsAllowed = false
                        state.advanceOnboarding()
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
