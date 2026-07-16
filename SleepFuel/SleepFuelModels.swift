import Foundation

// MARK: - Sleep & Allowance

/// Sleep window in hours (e.g. 22:30 → 6:30 = 8 hours)
typealias SleepHours = Double

/// Daily screen-time allowance in minutes
typealias AllowanceMinutes = Int

/// Converts sleep duration to allowance percentage (0–100)
/// 8h sleep = 100%, scales linearly
func allowancePercent(for sleepHours: SleepHours) -> Double {
    let percent = max(0, min(100, (sleepHours / 8.0) * 100))
    return percent
}

/// Computes allowed screen time for a sleep duration
func allowanceMinutes(cap: AllowanceMinutes, sleepHours: SleepHours) -> AllowanceMinutes {
    let percent = allowancePercent(for: sleepHours)
    return Int(Double(cap) * percent / 100.0)
}

// MARK: - Onboarding

enum OnboardingStep: String, CaseIterable, Equatable, Codable {
    case welcome
    case goodHands
    case motivational
    case bedtime
    case wakeTime
    case allowanceCap
    case goals
    case symptoms
    case blockedApps
    case blockingStrictness
    case notificationPermission
    case planSummary

    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }

    var total: Int {
        Self.allCases.count
    }
}

struct OnboardingState: Codable {
    var currentStep: OnboardingStep = .welcome
    var completed: Bool = false

    // Answers
    var heardAbout: String = ""
    var bedtime: Date = AppState.time(22, 30)
    var wakeTime: Date = AppState.time(6, 30)
    var allowanceCap: AllowanceMinutes = 180
    var goals: Set<String> = []
    var symptoms: Set<String> = []
    var blockedAppIDs: Set<String> = []
    var blockingStrictness: String = "medium"
    var notificationsAllowed: Bool = false
}

// MARK: - Night Record

struct NightRecord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let date: Date
    let scheduledMinutes: Int
    let actualSleepHours: Double
    let allowanceEarned: Int

    var allowancePercent: Double {
        SleepFuel.allowancePercent(for: actualSleepHours)
    }

    var grade: String {
        let percent = allowancePercent
        switch percent {
        case 90...: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

// MARK: - Blocking Strictness

enum BlockingStrictness: String, CaseIterable, Identifiable {
    case easy
    case medium
    case strict

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var detail: String {
        switch self {
        case .easy: return "1-tap to unblock"
        case .medium: return "Text rewrite to unblock"
        case .strict: return "Multiple barriers to unblock"
        }
    }
}

// MARK: - Goal & Symptom Options

let allGoals: [String: String] = [
    "better-sleep": "Better Sleep",
    "better-focus": "Better Focus",
    "less-addiction": "Less Addiction",
    "mental-health": "Better Mental Health",
    "relationships": "Better Relationships",
    "productivity": "More Productivity",
]

let allSymptoms: [String: String] = [
    "fatigue": "Fatigue / Tiredness",
    "poor-focus": "Poor Focus",
    "brain-fog": "Brain Fog",
    "anxiety": "Anxiety / Stress",
    "mood-swings": "Mood Swings",
    "sleep-issues": "Sleep Issues",
]

let allHeardAboutOptions: [String] = [
    "Search Engine",
    "Friend or Family",
    "Social Media",
    "App Store",
    "Podcast",
    "Other",
]

let allBlockedAppCategories: [String: [String]] = [
    "Social": ["Instagram", "TikTok", "X", "Snapchat", "Discord", "WhatsApp"],
    "Entertainment": ["YouTube", "Netflix", "Reddit"],
    "Productivity": ["Email", "Slack", "Telegram"],
    "Games": ["Gaming Apps"],
]

// MARK: - Time Formatting

enum TimeFormat {
    static func hoursMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }

    static func clock(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    static func sleepDuration(bedtime: Date, wakeTime: Date) -> Double {
        let cal = Calendar.current
        let b = cal.dateComponents([.hour, .minute], from: bedtime)
        let w = cal.dateComponents([.hour, .minute], from: wakeTime)
        let bm = Double((b.hour ?? 0) * 60 + (b.minute ?? 0))
        let wm = Double((w.hour ?? 0) * 60 + (w.minute ?? 0))
        var diffMinutes = wm - bm
        if diffMinutes < 0 { diffMinutes += 1440 }
        return diffMinutes / 60.0
    }
}
