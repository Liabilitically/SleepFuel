import SwiftUI

// MARK: - Flow container

struct OnboardingFlowView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step: Step = .pages

    enum Step: Equatable {
        case pages
        case permissions
        case apps
        case schedule
        case anchor
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            switch step {
            case .pages:
                OnboardingPagesView { advance(to: .permissions) }
                    .transition(stepTransition)
            case .permissions:
                PermissionSetupView(mode: .onboarding(onContinue: { advance(to: .apps) }))
                    .transition(stepTransition)
            case .apps:
                MockAppSelectionView(mode: .onboarding(onContinue: { advance(to: .schedule) }))
                    .transition(stepTransition)
            case .schedule:
                ScheduleSetupView(mode: .onboarding(onContinue: {
                    if state.anchorModeEnabled {
                        advance(to: .anchor)
                    } else {
                        state.completeOnboarding()
                    }
                }))
                .transition(stepTransition)
            case .anchor:
                MockAnchorSetupView(mode: .onboarding(onContinue: {
                    state.completeOnboarding()
                }))
                .transition(stepTransition)
            }
        }
        .animation(DS.motion(reduceMotion), value: step)
    }

    private var stepTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
    }

    private func advance(to next: Step) {
        withAnimation(DS.motion(reduceMotion)) {
            step = next
        }
    }
}

// MARK: - Four intro pages

struct OnboardingPagesView: View {
    let onFinished: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index = 0

    private struct Page {
        let symbol: String
        let headline: String
        let body: String
    }

    private let pages: [Page] = [
        Page(symbol: "bolt.fill",
             headline: "Your apps run on sleep.",
             body: "SleepFuel converts every hour of protected sleep into minutes of entertainment for tomorrow. No sleep, no fuel."),
        Page(symbol: "square.grid.2x2.fill",
             headline: "Choose what drains your night.",
             body: "Pick the apps that keep you up. They stay shielded until you've earned the fuel to run them."),
        Page(symbol: "moon.fill",
             headline: "Protect your sleep window.",
             body: "Set a bedtime and wake time. Every minute inside the window counts. Every breach costs you."),
        Page(symbol: "gauge.with.needle.fill",
             headline: "Earn tomorrow's fuel.",
             body: "Wake up to a full tank — or to the exact price of the night you actually had.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("SleepFuel")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
                Text(String(format: "%02d / %02d", index + 1, pages.count))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .monospacedDigit()
            }
            .padding(.bottom, DS.Space.xl)

            Spacer()

            Image(systemName: pages[index].symbol)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(DS.Palette.accent)
                .padding(.bottom, DS.Space.l)

            Text(pages[index].headline)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, DS.Space.m)

            Text(pages[index].body)
                .font(.system(size: 16))
                .foregroundStyle(DS.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            Spacer()
            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == index ? DS.Palette.accent : DS.Palette.elevated)
                        .frame(width: i == index ? 20 : 6, height: 6)
                }
            }
            .padding(.bottom, DS.Space.l)

            PrimaryButton(title: index == pages.count - 1 ? "Set up SleepFuel" : "Continue") {
                if index < pages.count - 1 {
                    withAnimation(DS.motion(reduceMotion)) {
                        index += 1
                    }
                } else {
                    onFinished()
                }
            }
        }
        .padding(DS.Space.l)
        .id(index)
    }
}
