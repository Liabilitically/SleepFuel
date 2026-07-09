import Foundation

/// Local implementation of the SleepFuel formula.
///
/// Protected Sleep Minutes =
///   Scheduled Sleep Window
///   - Emergency Unlock Minutes
///   - Late Start Penalty
///   - Missed Anchor Penalty
///   - Permission Disabled Penalty
///   - Manual Skip Penalty
///
/// Tomorrow Fuel Minutes = Protected Sleep Minutes x selected mode rate
enum FuelEngine {

    static func protectedMinutes(scheduled: Int, penalties: [Penalty]) -> Int {
        let deductions = penalties.reduce(0) { $0 + $1.minutes }
        return max(0, scheduled - deductions)
    }

    static func fuelMinutes(protectedMinutes: Int, mode: FuelMode, cap: Int) -> Int {
        let raw = Double(protectedMinutes) * Double(mode.minutesPerHour) / 60.0
        return min(cap, Int(raw.rounded()))
    }

    static func grade(protectedMinutes: Int, scheduled: Int) -> String {
        guard scheduled > 0 else { return "F" }
        let ratio = Double(protectedMinutes) / Double(scheduled)
        switch ratio {
        case 0.97...: return "A+"
        case 0.93..<0.97: return "A"
        case 0.90..<0.93: return "A-"
        case 0.87..<0.90: return "B+"
        case 0.83..<0.87: return "B"
        case 0.80..<0.83: return "B-"
        case 0.75..<0.80: return "C+"
        case 0.70..<0.75: return "C"
        case 0.60..<0.70: return "D"
        default: return "F"
        }
    }

    static func makeReport(
        date: Date,
        scheduled: Int,
        penalties: [Penalty],
        anchorCompleted: Bool,
        mode: FuelMode,
        cap: Int
    ) -> NightRecord {
        let protectedMins = protectedMinutes(scheduled: scheduled, penalties: penalties)
        let fuel = fuelMinutes(protectedMinutes: protectedMins, mode: mode, cap: cap)
        return NightRecord(
            date: date,
            scheduledMinutes: scheduled,
            penalties: penalties,
            anchorCompleted: anchorCompleted,
            protectedMinutes: protectedMins,
            fuelEarned: fuel,
            grade: grade(protectedMinutes: protectedMins, scheduled: scheduled)
        )
    }

    /// One useful takeaway, derived from the night's biggest leak.
    static func takeaway(for record: NightRecord) -> String {
        guard let worst = record.penalties.max(by: { $0.minutes < $1.minutes }) else {
            return "Clean night. Your full window converted to fuel — keep the same setup tonight."
        }
        switch worst.kind {
        case .lateStart:
            return "Your biggest leak was starting \(worst.minutes) minutes late. Arming 15 minutes before bedtime removes it entirely."
        case .emergencyUnlock:
            return "Emergency unlocks cost you \(worst.minutes) minutes. Each one is fuel you already earned — make tomorrow's unlock harder in Settings."
        case .missedAnchor:
            return "Skipping the anchor cost \(worst.minutes) minutes. Placing your phone across the room is the single highest-value habit here."
        case .permissionDisabled:
            return "Disabling permissions mid-night cost \(worst.minutes) minutes. If the block feels too strict, adjust the fuel mode instead."
        case .manualSkip:
            return "Ending the session early cost \(worst.minutes) minutes. Shorten your scheduled window if it doesn't match your real night."
        }
    }
}
