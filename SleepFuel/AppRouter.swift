import SwiftUI

// MARK: - Routes

enum RootRoute: Equatable {
    case launch
    case onboarding
    case main
}

enum MainRoute: Hashable {
    case history
    case settings
    case editApps
    case editSchedule
    case anchorSetup
}

// MARK: - Root view

struct RootView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        @Bindable var state = state

        return ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            switch state.route {
            case .launch:
                LaunchView()
                    .transition(.opacity)
            case .onboarding:
                OnboardingFlowView()
                    .transition(.opacity)
            case .main:
                MainView()
                    .transition(.opacity)
            }
        }
        .animation(DS.motion(reduceMotion), value: state.route)
        .sheet(isPresented: $state.showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Main container

struct MainView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state

        NavigationStack(path: $state.path) {
            DashboardView()
                .navigationDestination(for: MainRoute.self) { route in
                    switch route {
                    case .history:
                        HistoryView()
                    case .settings:
                        SettingsView()
                    case .editApps:
                        MockAppSelectionView(mode: .standalone)
                    case .editSchedule:
                        ScheduleSetupView(mode: .standalone)
                    case .anchorSetup:
                        MockAnchorSetupView(mode: .standalone)
                    }
                }
        }
        .fullScreenCover(isPresented: $state.showActiveSession) {
            ActiveSleepSessionView()
        }
        .fullScreenCover(item: $state.presentedReport) { report in
            MorningReportView(report: report)
        }
    }
}

/// Views that appear both inside onboarding and as pushed screens.
enum ScreenMode {
    case onboarding(onContinue: () -> Void)
    case standalone
}
