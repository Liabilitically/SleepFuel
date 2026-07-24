import ActivityKit
import Foundation

/// Drives the real lock screen / Dynamic Island Live Activity
/// during sleep mode.
@MainActor
enum LiveActivityManager {
    private static var activity: Activity<SleepActivityAttributes>?
    private static var lastPushed: SleepActivityAttributes.ContentState?

    static func startNight(bedtimeText: String, wakeTimeText: String, remaining: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        guard activity == nil else {
            update(remaining: remaining, isDraining: false)
            return
        }

        let attributes = SleepActivityAttributes(
            bedtimeText: bedtimeText,
            wakeTimeText: wakeTimeText
        )
        let state = SleepActivityAttributes.ContentState(
            remainingMinutes: remaining,
            isDraining: false
        )
        activity = try? Activity.request(
            attributes: attributes,
            content: .init(state: state, staleDate: nil)
        )
        lastPushed = state
    }

    static func update(remaining: Int, isDraining: Bool) {
        guard let activity else { return }
        let state = SleepActivityAttributes.ContentState(
            remainingMinutes: remaining,
            isDraining: isDraining
        )
        guard state != lastPushed else { return }
        lastPushed = state
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    static func endNight(finalRemaining: Int) {
        guard let current = activity else { return }
        activity = nil
        lastPushed = nil
        let state = SleepActivityAttributes.ContentState(
            remainingMinutes: finalRemaining,
            isDraining: false
        )
        Task {
            await current.end(.init(state: state, staleDate: nil), dismissalPolicy: .default)
        }
    }
}
