import Foundation
import Observation

@Observable
final class AppState {
    // MARK: - Root routing

    var route: RootRoute = .launch

    // MARK: - Onboarding

    var onboarding = OnboardingState()

    // MARK: - Home screen state

    var bedtime: Date = AppState.time(22, 30) {
        didSet { save() }
    }
    var wakeTime: Date = AppState.time(6, 30) {
        didSet { save() }
    }
    var allowanceCap: AllowanceMinutes = 180 {
        didSet { save() }
    }
    var blockedAppIDs: Set<String> = [] {
        didSet { save() }
    }
    var blockingStrictness: String = "medium" {
        didSet { save() }
    }

    var goals: Set<String> = [] {
        didSet { save() }
    }
    var symptoms: Set<String> = [] {
        didSet { save() }
    }

    // MARK: - Sleep session state

    var todayAllowance: AllowanceMinutes = 0
    var lastNight: NightRecord?
    var history: [NightRecord] = []

    var selectedBottomTab: BottomTab = .home

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
        blockedAppIDs = ["instagram", "tiktok", "youtube"]
        blockingStrictness = "medium"
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
        blockedAppIDs = onboarding.blockedAppIDs
        blockingStrictness = onboarding.blockingStrictness
        goals = onboarding.goals
        symptoms = onboarding.symptoms
        route = .main
        save()
    }

    func resetOnboarding() {
        onboarding = OnboardingState()
        route = .onboarding
    }

    // MARK: - Sleep tracking simulation

    func simulateNight(actualSleepHours: Double) {
        let allowance = allowanceMinutes(cap: allowanceCap, sleepHours: actualSleepHours)
        let record = NightRecord(
            date: Date(),
            scheduledMinutes: Int(TimeFormat.sleepDuration(bedtime: bedtime, wakeTime: wakeTime) * 60),
            actualSleepHours: actualSleepHours,
            allowanceEarned: allowance
        )
        lastNight = record
        history.insert(record, at: 0)
        todayAllowance = allowance
        save()
    }

    // MARK: - Persistence

    func save() {
        PrototypeStorage.save(PrototypeSnapshot(
            onboardingCompleted: onboarding.completed,
            bedtime: bedtime,
            wakeTime: wakeTime,
            allowanceCap: allowanceCap,
            blockedAppIDs: blockedAppIDs,
            blockingStrictness: blockingStrictness,
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
        blockedAppIDs = snapshot.blockedAppIDs
        blockingStrictness = snapshot.blockingStrictness
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
