import Foundation

struct PrototypeSnapshot: Codable {
    var onboardingCompleted: Bool
    var notificationsAllowed: Bool
    var bedtime: Date
    var wakeTime: Date
    var allowanceCap: Int
    var goals: Set<String>
    var symptoms: Set<String>
    var phase: DayPhase
    var nightStartedAt: Date?
    var nightDrainedMinutes: Double
    var todayRemaining: Double
    var lastNight: NightRecord?
    var history: [NightRecord]
}

enum PrototypeStorage {
    private static let key = "sleepfuel.v4.snapshot"

    static func load() -> PrototypeSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PrototypeSnapshot.self, from: data)
    }

    static func save(_ snapshot: PrototypeSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
