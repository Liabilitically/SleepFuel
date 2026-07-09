import Foundation

// MARK: - Fuel mode

enum FuelMode: String, Codable, CaseIterable, Identifiable {
    case strict
    case normal
    case generous

    var id: String { rawValue }

    /// Entertainment minutes earned per hour of protected sleep.
    var minutesPerHour: Int {
        switch self {
        case .strict: return 10
        case .normal: return 15
        case .generous: return 20
        }
    }

    var title: String {
        switch self {
        case .strict: return "Strict"
        case .normal: return "Normal"
        case .generous: return "Generous"
        }
    }

    var detail: String {
        "1 hr protected sleep = \(minutesPerHour) min fuel"
    }

    var requiresPro: Bool {
        self == .strict
    }
}

// MARK: - Blockable targets

struct BlockTarget: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let isCategory: Bool
}

// MARK: - Session

enum SessionState: String, Codable {
    case notArmed
    case armed
    case active
    case completed
    case failed

    var label: String {
        switch self {
        case .notArmed: return "Not armed"
        case .armed: return "Armed"
        case .active: return "Active"
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }
}

struct ActiveSession: Codable {
    var startedAt: Date
    var simulatedMinutes: Int
    var penalties: [Penalty]
    var anchorEngaged: Bool
}

// MARK: - Penalties

enum PenaltyKind: String, Codable, CaseIterable {
    case lateStart
    case emergencyUnlock
    case missedAnchor
    case permissionDisabled
    case manualSkip

    var label: String {
        switch self {
        case .lateStart: return "Late start"
        case .emergencyUnlock: return "Emergency unlock"
        case .missedAnchor: return "Missed anchor"
        case .permissionDisabled: return "Permission disabled"
        case .manualSkip: return "Session ended early"
        }
    }
}

struct Penalty: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let kind: PenaltyKind
    let minutes: Int
}

// MARK: - Night record

struct NightRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let date: Date
    let scheduledMinutes: Int
    let penalties: [Penalty]
    let anchorCompleted: Bool
    let protectedMinutes: Int
    let fuelEarned: Int
    let grade: String

    var emergencyUnlockCount: Int {
        penalties.filter { $0.kind == .emergencyUnlock }.count
    }

    var missedAnchor: Bool {
        penalties.contains { $0.kind == .missedAnchor }
    }
}

// MARK: - Formatting helpers

enum TimeFormat {
    /// 462 -> "7h 42m"
    static func hoursMinutes(_ minutes: Int) -> String {
        let m = max(0, minutes)
        let h = m / 60
        let r = m % 60
        if h == 0 { return "\(r)m" }
        if r == 0 { return "\(h)h" }
        return "\(h)h \(r)m"
    }

    static func clock(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func weekdayShort(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }
}
