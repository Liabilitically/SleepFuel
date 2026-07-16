import Foundation
import Observation

/// Where the user is in the daily cycle.
/// day → night (sleep mode) → morning (report) → day …
enum DayPhase: Equatable {
    case day
    case night
    case morning
}

@Observable
final class AppState {
    // MARK: - Root routing

    var route: RootRoute = .launch

    // MARK: - Onboarding

    var onboarding = OnboardingState()

    // MARK: - Settings

    var bedtime: Date = AppState.time(22, 30) {
        didSet { save() }
    }
    var wakeTime: Date = AppState.time(6, 30) {
        didSet { save() }
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

    // MARK: - Daily cycle

    var phase: DayPhase = .day

    /// Allowance minutes lost so far tonight from the phone being open.
    var nightDrainedMinutes: Double = 0

    var todayAllowance: AllowanceMinutes = 0
    var lastNight: NightRecord?
    var history: [NightRecord] = []

    var selectedBottomTab: BottomTab = .home

    // MARK: - Derived

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

    /// What tomorrow's allowance would be if the night ended right now.
    var tomorrowAllowance: AllowanceMinutes {
        max(0, allowanceCap - Int(nightDrainedMinutes.rounded()))
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
        todayAllowance = mockSleep.allowanceEarned
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
        todayAllowance = allowanceCap
        route = .main
        save()
    }

    func resetOnboarding() {
        onboarding = OnboardingState()
        phase = .day
        route = .onboarding
    }

    // MARK: - Night (sleep mode)

    func startNight() {
        nightDrainedMinutes = 0
        phase = .night
    }

    /// Called while the phone is open during sleep time.
    /// Drains tomorrow's allowance for the seconds the screen was on.
    func nightTick(openSeconds: Double) {
        let drained = nightDrainedMinutes + nightDrainPerMinute * openSeconds / 60
        nightDrainedMinutes = min(Double(allowanceCap), drained)
    }

    func endNight() {
        let cap = Double(allowanceCap)
        let sleptFraction = cap > 0 ? max(0, 1 - nightDrainedMinutes / cap) : 1
        let sleepHours = (sleepWindowMinutes / 60) * sleptFraction
        let record = NightRecord(
            date: Date(),
            scheduledMinutes: Int(sleepWindowMinutes),
            actualSleepHours: (sleepHours * 10).rounded() / 10,
            allowanceEarned: tomorrowAllowance
        )
        lastNight = record
        history.insert(record, at: 0)
        todayAllowance = record.allowanceEarned
        phase = .morning
        save()
    }

    func startDay() {
        phase = .day
    }

    // MARK: - Day (allowance depletion)

    /// One minute of phone use during the day.
    func useDayMinute() {
        guard phase == .day, onboarding.completed, todayAllowance > 0 else { return }
        todayAllowance -= 1
        save()
    }

    /// Emergency bypass: grants a short window of time after the user
    /// retypes the emergency paragraph exactly.
    func emergencyUnlock() {
        todayAllowance += 15
        save()
    }

    // MARK: - Persistence

    func save() {
        PrototypeStorage.save(PrototypeSnapshot(
            onboardingCompleted: onboarding.completed,
            bedtime: bedtime,
            wakeTime: wakeTime,
            allowanceCap: allowanceCap,
            goals: goals,
            symptoms: symptoms,
            todayAllowance: todayAllowance,
            lastNight: lastNight,
            history: history
        ))
    }

    private func apply(_ snapshot: PrototypeSnapshot) {
        onboarding.completed = snapshot.onboardingCompleted
        bedtime = snapshot.bedtime
        wakeTime = snapshot.wakeTime
        allowanceCap = snapshot.allowanceCap
        goals = snapshot.goals
        symptoms = snapshot.symptoms
        todayAllowance = snapshot.todayAllowance
        lastNight = snapshot.lastNight
        history = snapshot.history

        if onboarding.completed {
            route = .main
        } else {
            route = .onboarding
        }
    }

    static func time(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}

// MARK: - Routing

enum RootRoute: Equatable {
    case launch
    case onboarding
    case main
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
