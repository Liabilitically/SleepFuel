import Foundation

/// Snapshot of everything the prototype persists between launches.
struct PrototypeSnapshot: Codable {
    var hasCompletedOnboarding: Bool
    var isPro: Bool
    var screenTimeGranted: Bool
    var notificationsGranted: Bool
    var anchorConfigured: Bool
    var selectedTargetIDs: Set<String>
    var bedtime: Date
    var wakeTime: Date
    var repeatDays: Set<Int>
    var fuelMode: FuelMode
    var dailyFuelCap: Int
    var anchorModeEnabled: Bool
    var emergencyUnlockMinutes: Int
    var availableFuel: Int
    var sessionState: SessionState
    var session: ActiveSession?
    var lastReport: NightRecord?
    var history: [NightRecord]
}

enum PrototypeStorage {
    private static let key = "sleepfuel.prototype.v1"

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
