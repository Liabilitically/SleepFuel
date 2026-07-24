import Foundation
import Observation

/// Where the user is in the daily cycle.
/// day → night (sleep mode) → morning (report) → day …
enum DayPhase: String, Equatable, Codable {
    case day
    case night
    case morning
}

@Observable
@MainActor
final class AppState {
    // MARK: - Root routing

    var route: RootRoute = .launch

    // MARK: - Onboarding

    var onboarding = OnboardingState()

    // MARK: - Settings

    var bedtime: Date = AppState.time(22, 30) {
        didSet { scheduleChanged() }
    }
    var wakeTime: Date = AppState.time(6, 30) {
        didSet { scheduleChanged() }
    }
    var allowanceCap: AllowanceMinutes = 180 {
        didSet { save() }
    }

    var goals: Set<String> = [] {
        didSet { save() }
    }
    var symptoms: Set<String> = [] {
        didSet { save() }
    }
    var notificationsAllowed: Bool = false

    // MARK: - Daily cycle

    var phase: DayPhase = .day
    var nightStartedAt: Date?

    /// Allowance minutes lost so far tonight from the phone being open.
    var nightDrainedMinutes: Double = 0

    /// Minutes of screen time left today. Double for smooth accrual.
    var todayRemaining: Double = 0

    var lastNight: NightRecord?
    var history: [NightRecord] = []

    var selectedBottomTab: BottomTab = .home

    /// Which Settings sub-screen is open, if any. While one is open the
    /// bottom nav morphs into a single back chevron.
    var settingsEditor: SettingsEditor? = nil

    /// When the app last became active; foreground time is charged
    /// against the current phase from this mark.
    @ObservationIgnored private var foregroundSince: Date?
    @ObservationIgnored private var lastPushedKey: String = ""

    // MARK: - Derived

    var todayAllowance: AllowanceMinutes {
        max(0, Int(todayRemaining.rounded(.down)))
    }

    var tomorrowAllowance: AllowanceMinutes {
        max(0, allowanceCap - Int(nightDrainedMinutes.rounded()))
    }

    var sleepWindowMinutes: Double {
        TimeFormat.sleepDuration(bedtime: bedtime, wakeTime: wakeTime) * 60
    }

    /// Allowance lost per minute the phone is open during sleep time.
    /// Sleeping the full window keeps the full cap; being on the phone
    /// all night drains it to zero.
    var nightDrainPerMinute: Double {
        guard sleepWindowMinutes > 0 else { return 1 }
        return Double(allowanceCap) / sleepWindowMinutes
    }

    /// Out of time for today: every non-essential app shows the block screen.
    var isBlocked: Bool {
        phase == .day && onboarding.completed && todayAllowance <= 0
    }

    // MARK: - Init

    init() {
        loadOrSeedDefaults()
    }

    private func loadOrSeedDefaults() {
        if let snapshot = PrototypeStorage.load() {
            apply(snapshot)
        } else {
            seedDefaults()
        }
    }

    private func seedDefaults() {
        bedtime = Self.time(22, 30)
        wakeTime = Self.time(6, 30)
        allowanceCap = 180
        goals = ["better-sleep", "better-focus"]
        symptoms = ["fatigue", "poor-focus"]

        onboarding.completed = true
        onboarding.bedtime = bedtime
        onboarding.wakeTime = wakeTime
        onboarding.allowanceCap = allowanceCap

        // Seed last night's mock data
        let mockSleep = NightRecord(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            scheduledMinutes: 480,
            actualSleepHours: 7.5,
            allowanceEarned: 160
        )
        lastNight = mockSleep
        history = [mockSleep]
        todayRemaining = Double(mockSleep.allowanceEarned)
    }

    // MARK: - App lifecycle (real time tracking)

    /// Called when the app comes to the foreground.
    func appBecameActive(now: Date = Date()) {
        foregroundSince = now
        syncWithClock(now: now)
        pushExternalState()
    }

    /// Called when the app leaves the foreground. While backgrounded or
    /// locked, no time is charged — exactly the behavior the product wants.
    func appResignedActive(now: Date = Date()) {
        accrue(now: now)
        foregroundSince = nil
        pushExternalState()
        save()
    }

    /// Charge foreground time since the last mark to the current phase.
    func accrue(now: Date = Date()) {
        guard onboarding.completed, let since = foregroundSince else { return }
        let minutes = now.timeIntervalSince(since) / 60
        guard minutes > 0 else { return }
        foregroundSince = now

        switch phase {
        case .night:
            let drained = nightDrainedMinutes + minutes * nightDrainPerMinute
            nightDrainedMinutes = min(Double(allowanceCap), drained)
        case .day:
            todayRemaining = max(0, todayRemaining - minutes)
        case .morning:
            break
        }
    }

    /// Runs once a minute while the app is open: charges time and
    /// enters/exits sleep mode by the clock.
    func minuteTick(now: Date = Date()) {
        accrue(now: now)
        syncWithClock(now: now)
        pushExternalState()
        save()
    }

    /// Enter or exit sleep mode automatically based on the wall clock.
    private func syncWithClock(now: Date) {
        guard onboarding.completed else { return }
        let inWindow = sleepWindow(containing: now) != nil
        if inWindow, phase == .day {
            beginNight(now: now)
        } else if !inWindow, phase == .night {
            finishNight(now: now)
        }
    }

    /// The sleep window (start–end) that contains `now`, if any.
    private func sleepWindow(containing now: Date) -> (start: Date, end: Date)? {
        let cal = Calendar.current
        let lengthSeconds = sleepWindowMinutes * 60
        guard lengthSeconds > 0 else { return nil }

        for dayOffset in [-1, 0] {
            guard let day = cal.date(byAdding: .day, value: dayOffset, to: now),
                  let start = cal.date(
                      bySettingHour: cal.component(.hour, from: bedtime),
                      minute: cal.component(.minute, from: bedtime),
                      second: 0,
                      of: day
                  ) else { continue }
            let end = start.addingTimeInterval(lengthSeconds)
            if now >= start && now < end {
                return (start, end)
            }
        }
        return nil
    }

    // MARK: - Night (sleep mode)

    func startNightManually(now: Date = Date()) {
        beginNight(now: now)
    }

    private func beginNight(now: Date) {
        guard phase != .night else { return }
        accrue(now: now)
        nightStartedAt = now
        nightDrainedMinutes = 0
        phase = .night
        LiveActivityManager.startNight(
            bedtimeText: TimeFormat.clock(bedtime),
            wakeTimeText: TimeFormat.clock(wakeTime),
            remaining: allowanceCap
        )
        pushExternalState()
        save()
    }

    func finishNight(now: Date = Date()) {
        guard phase == .night else { return }
        accrue(now: now)

        let cap = Double(allowanceCap)
        let sleptFraction = cap > 0 ? max(0, 1 - nightDrainedMinutes / cap) : 1
        let sleepHours = (sleepWindowMinutes / 60) * sleptFraction
        let record = NightRecord(
            date: now,
            scheduledMinutes: Int(sleepWindowMinutes),
            actualSleepHours: (sleepHours * 10).rounded() / 10,
            allowanceEarned: tomorrowAllowance
        )
        lastNight = record
        history.insert(record, at: 0)
        todayRemaining = Double(record.allowanceEarned)
        nightStartedAt = nil
        phase = .morning
        LiveActivityManager.endNight(finalRemaining: record.allowanceEarned)
        pushExternalState()
        save()
    }

    func startDay() {
        phase = .day
        pushExternalState()
        save()
    }

    /// Emergency bypass: grants a short window of time after the user
    /// retypes the emergency paragraph exactly.
    func emergencyUnlock() {
        todayRemaining += 15
        pushExternalState()
        save()
    }

    // MARK: - External surfaces (widget + live activity)

    /// Mirrors current state to the widget (app group) and the
    /// Live Activity. Deduplicated, so it is cheap to call often.
    func pushExternalState() {
        guard onboarding.completed else { return }
        let remaining = phase == .night ? tomorrowAllowance : todayAllowance
        let key = "\(phase.rawValue)-\(remaining)-\(allowanceCap)"
        guard key != lastPushedKey else { return }
        lastPushedKey = key

        SharedStore.write(remaining: remaining, cap: allowanceCap, phase: phase.rawValue)
        if phase == .night {
            LiveActivityManager.update(remaining: remaining, isDraining: foregroundSince != nil)
        }
    }

    // MARK: - Onboarding progression

    func advanceOnboarding() {
        let allSteps = OnboardingStep.allCases
        if let currentIndex = allSteps.firstIndex(of: onboarding.currentStep) {
            if currentIndex < allSteps.count - 1 {
                onboarding.currentStep = allSteps[currentIndex + 1]
            } else {
                completeOnboarding()
            }
        }
    }

    func backOnboarding() {
        let allSteps = OnboardingStep.allCases
        if let currentIndex = allSteps.firstIndex(of: onboarding.currentStep) {
            if currentIndex > 0 {
                onboarding.currentStep = allSteps[currentIndex - 1]
            }
        }
    }

    func completeOnboarding() {
        onboarding.completed = true
        bedtime = onboarding.bedtime
        wakeTime = onboarding.wakeTime
        allowanceCap = onboarding.allowanceCap
        goals = onboarding.goals
        symptoms = onboarding.symptoms
        notificationsAllowed = onboarding.notificationsAllowed
        todayRemaining = Double(allowanceCap)
        route = .main
        if notificationsAllowed {
            NotificationManager.reschedule(bedtime: bedtime, wakeTime: wakeTime)
        }
        pushExternalState()
        save()
    }

    func resetOnboarding() {
        onboarding = OnboardingState()
        phase = .day
        NotificationManager.cancelAll()
        route = .onboarding
    }

    private func scheduleChanged() {
        save()
        if notificationsAllowed, onboarding.completed {
            NotificationManager.reschedule(bedtime: bedtime, wakeTime: wakeTime)
        }
    }

    // MARK: - Persistence

    func save() {
        PrototypeStorage.save(PrototypeSnapshot(
            onboardingCompleted: onboarding.completed,
            notificationsAllowed: notificationsAllowed,
            bedtime: bedtime,
            wakeTime: wakeTime,
            allowanceCap: allowanceCap,
            goals: goals,
            symptoms: symptoms,
            phase: phase,
            nightStartedAt: nightStartedAt,
            nightDrainedMinutes: nightDrainedMinutes,
            todayRemaining: todayRemaining,
            lastNight: lastNight,
            history: history
        ))
    }

    private func apply(_ snapshot: PrototypeSnapshot) {
        onboarding.completed = snapshot.onboardingCompleted
        notificationsAllowed = snapshot.notificationsAllowed
        bedtime = snapshot.bedtime
        wakeTime = snapshot.wakeTime
        allowanceCap = snapshot.allowanceCap
        goals = snapshot.goals
        symptoms = snapshot.symptoms
        phase = snapshot.phase
        nightStartedAt = snapshot.nightStartedAt
        nightDrainedMinutes = snapshot.nightDrainedMinutes
        todayRemaining = snapshot.todayRemaining
        lastNight = snapshot.lastNight
        history = snapshot.history

        if onboarding.completed {
            route = .main
        } else {
            route = .onboarding
        }
    }

    nonisolated static func time(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}

// MARK: - Routing

enum RootRoute: Equatable {
    case launch
    case onboarding
    case main
}

enum SettingsEditor: Equatable {
    case bedtime
    case wakeTime
    case allowance
}

enum BottomTab: Int, CaseIterable {
    case home = 0
    case history = 1
    case settings = 2

    var label: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape.fill"
        }
    }
}
