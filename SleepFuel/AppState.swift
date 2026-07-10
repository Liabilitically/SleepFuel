import Foundation
import Observation

@Observable
final class AppState {

    // MARK: - Routing

    var route: RootRoute = .launch
    var path: [MainRoute] = []
    var showPaywall = false
    var showActiveSession = false
    var showHistory = false
    var presentedReport: NightRecord?

    // MARK: - Onboarding & account

    var hasCompletedOnboarding = false
    var isPro = false

    // MARK: - Mock permissions

    var screenTimeGranted = false
    var notificationsGranted = false
    var anchorConfigured = false

    // MARK: - Blocked apps

    var selectedTargetIDs: Set<String> = MockData.defaultSelection
    static let freeSelectionLimit = 3

    var selectedTargets: [BlockTarget] {
        MockData.allTargets.filter { selectedTargetIDs.contains($0.id) }
    }

    var atFreeLimit: Bool {
        !isPro && selectedTargetIDs.count >= Self.freeSelectionLimit
    }

    // MARK: - Schedule

    var bedtime: Date = AppState.time(22, 30)
    var wakeTime: Date = AppState.time(6, 30)
    var repeatDays: Set<Int> = [0, 1, 2, 3, 4, 5, 6]
    var fuelMode: FuelMode = .normal
    var dailyFuelCap: Int = 180
    var anchorModeEnabled = true
    var emergencyUnlockMinutes = 10

    var scheduledWindowMinutes: Int {
        let cal = Calendar.current
        let b = cal.dateComponents([.hour, .minute], from: bedtime)
        let w = cal.dateComponents([.hour, .minute], from: wakeTime)
        let bm = (b.hour ?? 0) * 60 + (b.minute ?? 0)
        let wm = (w.hour ?? 0) * 60 + (w.minute ?? 0)
        let diff = wm - bm
        return diff > 0 ? diff : diff + 1440
    }

    var sleepWindowLabel: String {
        "\(TimeFormat.clock(bedtime)) – \(TimeFormat.clock(wakeTime))"
    }

    // MARK: - Fuel & session

    var availableFuel = 112
    var sessionState: SessionState = .notArmed
    var session: ActiveSession?
    var lastReport: NightRecord?
    var history: [NightRecord] = []

    // MARK: - Init

    init() {
        if let snapshot = PrototypeStorage.load() {
            apply(snapshot)
        } else {
            seedDefaults()
        }
    }

    private func seedDefaults() {
        history = MockData.seededHistory()
        lastReport = history.first
        availableFuel = lastReport?.fuelEarned ?? 0
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        route = .main
        save()
    }

    // MARK: - Session lifecycle

    func armTonight() {
        guard sessionState == .notArmed || sessionState == .completed || sessionState == .failed else { return }
        sessionState = .armed
        save()
    }

    func disarm() {
        guard sessionState == .armed else { return }
        sessionState = .notArmed
        save()
    }

    func startSession() {
        guard sessionState == .armed else { return }
        session = ActiveSession(
            startedAt: Date(),
            simulatedMinutes: 0,
            penalties: [],
            anchorEngaged: anchorModeEnabled && anchorConfigured
        )
        sessionState = .active
        showActiveSession = true
        save()
    }

    func simulateHourPassed() {
        guard var current = session else { return }
        current.simulatedMinutes += 60
        session = current
        save()
    }

    func applyEmergencyUnlock() {
        guard var current = session else { return }
        current.penalties.append(Penalty(kind: .emergencyUnlock, minutes: emergencyUnlockMinutes))
        session = current
        save()
    }

    func sessionElapsedMinutes(now: Date = Date()) -> Int {
        guard let session else { return 0 }
        let live = Int(now.timeIntervalSince(session.startedAt) / 60)
        return min(scheduledWindowMinutes, max(0, live) + session.simulatedMinutes)
    }

    func sessionPenaltyTotal() -> Int {
        session?.penalties.reduce(0) { $0 + $1.minutes } ?? 0
    }

    /// Fuel the full night would earn if nothing else goes wrong.
    func projectedFuel() -> Int {
        guard let session else { return 0 }
        let protectedMins = FuelEngine.protectedMinutes(
            scheduled: scheduledWindowMinutes,
            penalties: session.penalties
        )
        return FuelEngine.fuelMinutes(protectedMinutes: protectedMins, mode: fuelMode, cap: dailyFuelCap)
    }

    /// Fuel earned by the minutes already protected tonight.
    func fuelGeneratedSoFar(now: Date = Date()) -> Int {
        let earnedMinutes = max(0, sessionElapsedMinutes(now: now) - sessionPenaltyTotal())
        return FuelEngine.fuelMinutes(protectedMinutes: earnedMinutes, mode: fuelMode, cap: dailyFuelCap)
    }

    func completeNight() {
        finishSession(failed: false)
    }

    func failNight() {
        guard var current = session else { return }
        let remaining = max(0, scheduledWindowMinutes - sessionElapsedMinutes())
        if remaining > 0 {
            current.penalties.append(Penalty(kind: .manualSkip, minutes: remaining))
        }
        session = current
        finishSession(failed: true)
    }

    private func finishSession(failed: Bool) {
        guard let current = session else { return }
        let report = FuelEngine.makeReport(
            date: Date(),
            scheduled: scheduledWindowMinutes,
            penalties: current.penalties,
            anchorCompleted: current.anchorEngaged,
            mode: fuelMode,
            cap: dailyFuelCap
        )
        lastReport = report
        history.insert(report, at: 0)
        availableFuel = report.fuelEarned
        sessionState = failed ? .failed : .completed
        session = nil
        showActiveSession = false
        save()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.presentedReport = report
        }
    }

    // MARK: - Selection

    /// Returns false when the free limit blocks the change.
    @discardableResult
    func toggleTarget(_ id: String) -> Bool {
        if selectedTargetIDs.contains(id) {
            selectedTargetIDs.remove(id)
            save()
            return true
        }
        if atFreeLimit {
            return false
        }
        selectedTargetIDs.insert(id)
        save()
        return true
    }

    // MARK: - Subscription

    func startPro() {
        isPro = true
        save()
    }

    // MARK: - Persistence

    func save() {
        PrototypeStorage.save(PrototypeSnapshot(
            hasCompletedOnboarding: hasCompletedOnboarding,
            isPro: isPro,
            screenTimeGranted: screenTimeGranted,
            notificationsGranted: notificationsGranted,
            anchorConfigured: anchorConfigured,
            selectedTargetIDs: selectedTargetIDs,
            bedtime: bedtime,
            wakeTime: wakeTime,
            repeatDays: repeatDays,
            fuelMode: fuelMode,
            dailyFuelCap: dailyFuelCap,
            anchorModeEnabled: anchorModeEnabled,
            emergencyUnlockMinutes: emergencyUnlockMinutes,
            availableFuel: availableFuel,
            sessionState: sessionState,
            session: session,
            lastReport: lastReport,
            history: history
        ))
    }

    private func apply(_ s: PrototypeSnapshot) {
        hasCompletedOnboarding = s.hasCompletedOnboarding
        isPro = s.isPro
        screenTimeGranted = s.screenTimeGranted
        notificationsGranted = s.notificationsGranted
        anchorConfigured = s.anchorConfigured
        selectedTargetIDs = s.selectedTargetIDs
        bedtime = s.bedtime
        wakeTime = s.wakeTime
        repeatDays = s.repeatDays
        fuelMode = s.fuelMode
        dailyFuelCap = s.dailyFuelCap
        anchorModeEnabled = s.anchorModeEnabled
        emergencyUnlockMinutes = s.emergencyUnlockMinutes
        availableFuel = s.availableFuel
        sessionState = s.sessionState
        session = s.session
        lastReport = s.lastReport
        history = s.history

        // An interrupted active session resumes cleanly as armed.
        if sessionState == .active {
            sessionState = .armed
            session = nil
        }
    }

    func resetPrototype() {
        PrototypeStorage.clear()
        hasCompletedOnboarding = false
        isPro = false
        screenTimeGranted = false
        notificationsGranted = false
        anchorConfigured = false
        selectedTargetIDs = MockData.defaultSelection
        bedtime = Self.time(22, 30)
        wakeTime = Self.time(6, 30)
        repeatDays = [0, 1, 2, 3, 4, 5, 6]
        fuelMode = .normal
        dailyFuelCap = 180
        anchorModeEnabled = true
        emergencyUnlockMinutes = 10
        sessionState = .notArmed
        session = nil
        presentedReport = nil
        showActiveSession = false
        showHistory = false
        showPaywall = false
        path = []
        seedDefaults()
        route = .onboarding
    }

    // MARK: - Helpers

    static func time(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
