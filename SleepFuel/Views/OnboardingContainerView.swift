import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back button and progress
                HStack {
                    if state.onboarding.currentStep != .welcome {
                        Button {
                            state.backOnboarding()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(DS.Palette.textSecondary)
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        Spacer()
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(DS.Palette.elevated)
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(DS.Palette.accent)
                                .frame(
                                    width: geo.size.width
                                        * CGFloat(state.onboarding.currentStep.index + 1)
                                        / CGFloat(state.onboarding.currentStep.total)
                                )
                        }
                        .frame(height: 3)
                    }
                    .frame(width: 120, height: 3)

                    Spacer()
                }
                .padding(.horizontal, DS.Space.l)
                .padding(.vertical, DS.Space.m)

                // Step content
                ScrollView {
                    stepContent
                        .padding(DS.Space.l)
                }

                Spacer(minLength: 0)

                // Footer: Next button
                VStack(spacing: DS.Space.s) {
                    PrimaryButton(
                        title: "Next",
                        isEnabled: canAdvance,
                        action: { state.advanceOnboarding() }
                    )
                }
                .padding(DS.Space.l)
            }
        }
        .animation(DS.motion(reduceMotion), value: state.onboarding.currentStep)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch state.onboarding.currentStep {
        case .welcome:
            OnboardingWelcomeView()
        case .goodHands:
            OnboardingGoodHandsView()
        case .motivational:
            OnboardingMotivationalView()
        case .bedtime:
            OnboardingBedtimeView()
        case .wakeTime:
            OnboardingWakeTimeView()
        case .allowanceCap:
            OnboardingAllowanceCapView()
        case .goals:
            OnboardingGoalsView()
        case .symptoms:
            OnboardingSymptonsView()
        case .blockedApps:
            OnboardingBlockedAppsView()
        case .blockingStrictness:
            OnboardingStrictnessView()
        case .notificationPermission:
            OnboardingNotificationsView()
        case .planSummary:
            OnboardingPlanView()
        }
    }

    private var canAdvance: Bool {
        switch state.onboarding.currentStep {
        case .welcome:
            return !state.onboarding.heardAbout.isEmpty
        case .goodHands, .motivational:
            return true
        case .bedtime, .wakeTime, .allowanceCap:
            return true
        case .goals:
            return !state.onboarding.goals.isEmpty
        case .symptoms:
            return true
        case .blockedApps:
            return !state.onboarding.blockedAppIDs.isEmpty
        case .blockingStrictness:
            return !state.onboarding.blockingStrictness.isEmpty
        case .notificationPermission, .planSummary:
            return true
        }
    }
}
