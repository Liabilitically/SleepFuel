import Foundation
import WidgetKit

/// Data shared between the app and its widgets through the app group.
/// Falls back to standard defaults when the group container is unavailable
/// (e.g. re-signed builds where the app group was stripped).
enum SharedStore {
    static let suiteName = "group.com.calyantech.sleepfuel"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    private enum Key {
        static let remaining = "shared.remainingMinutes"
        static let cap = "shared.capMinutes"
        static let phase = "shared.phase"
    }

    static func write(remaining: Int, cap: Int, phase: String) {
        let d = defaults
        d.set(remaining, forKey: Key.remaining)
        d.set(cap, forKey: Key.cap)
        d.set(phase, forKey: Key.phase)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func read() -> (remaining: Int, cap: Int, phase: String) {
        let d = defaults
        let cap = d.integer(forKey: Key.cap)
        return (
            remaining: d.integer(forKey: Key.remaining),
            cap: cap == 0 ? 180 : cap,
            phase: d.string(forKey: Key.phase) ?? "day"
        )
    }
}
