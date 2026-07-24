import SwiftUI

struct LaunchView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false

    var body: some View {
        VStack(spacing: DS.Space.m) {
            Image(systemName: "moon.fill")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(DS.Palette.accent)

            Text("SleepFuel")
                .font(.system(size: 28, weight: .bold))
                .tracking(0.4)
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Protect your sleep. Earn tomorrow's entertainment.")
                .font(.system(size: 13))
                .foregroundStyle(DS.Palette.textTertiary)
                .multilineTextAlignment(.center)
        }
        .opacity(visible ? 1 : 0)
        .task {
            withAnimation(DS.motion(reduceMotion)) {
                visible = true
            }
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(DS.motion(reduceMotion)) {
                state.route = state.onboarding.completed ? .main : .onboarding
            }
        }
    }
}
