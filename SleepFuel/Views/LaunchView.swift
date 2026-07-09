import SwiftUI

struct LaunchView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false

    var body: some View {
        VStack(spacing: DS.Space.m) {
            Image(systemName: "moon.fill")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(DS.Palette.accent)

            Text("SleepFuel")
                .font(.system(size: 24, weight: .bold))
                .tracking(0.4)
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Protect your sleep window. Earn tomorrow's entertainment.")
                .font(.system(size: 13))
                .foregroundStyle(DS.Palette.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Space.xl)
        }
        .opacity(visible ? 1 : 0)
        .onAppear {
            withAnimation(DS.motion(reduceMotion)) {
                visible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(DS.motion(reduceMotion)) {
                    state.route = state.hasCompletedOnboarding ? .main : .onboarding
                }
            }
        }
    }
}
