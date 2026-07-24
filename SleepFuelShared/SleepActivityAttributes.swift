import ActivityKit
import Foundation

/// The Live Activity shown on the lock screen and Dynamic Island
/// during sleep mode. Defined identically in the app and the widget
/// extension so ActivityKit can match them.
struct SleepActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Minutes of screen time left for tomorrow.
        var remainingMinutes: Int
        /// True while the phone is open during sleep time.
        var isDraining: Bool
    }

    var bedtimeText: String
    var wakeTimeText: String
}
