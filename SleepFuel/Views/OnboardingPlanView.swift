import SwiftUI

struct OnboardingPlanView: View {
    @Environment(AppState.self) private var state

    private var sleepDurationHours: Double {
        TimeFormat.sleepDuration(bedtime: state.onboarding.bedtime, wakeTime: state.onboarding.wakeTime)
    }

    private var goalsDisplay: String {
        let selected = state.onboarding.goals
            .map { allGoals[$0] ?? "" }
            .joined(separator: ", ")
        return selected.isEmpty ? "None" : selected
    }

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "Your plan is ready",
                subtitle: "Sleep the full night and this is yours every day."
            )

            VStack(spacing: DS.Space.m) {
                summaryCard("Bed time", TimeFormat.clock(state.onboarding.bedtime))
                summaryCard("Wake time", TimeFormat.clock(state.onboarding.wakeTime))
                summaryCard("Sleep", String(format: "%.1f hours", sleepDurationHours))
                summaryCard("Phone time each day", "\(state.onboarding.allowanceCap) min")
                summaryCard("Goals", goalsDisplay)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func summaryCard(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DS.Palette.textTertiary)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DS.Palette.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .dsCard()
    }
}
