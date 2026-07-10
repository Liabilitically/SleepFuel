import SwiftUI

// MARK: - Flow container

/// Owns the static chrome (progress bar, continue button). Only the step
/// content between them transitions, so shared elements never shift.
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

            if step == .pages {
                OnboardingPagesView {
                    withAnimation(DS.motion(reduceMotion)) {
                        step = .permissions
                    }
                }
                .transition(.opacity)
            } else {
                setupFlow
                    .transition(.opacity)
            }
        }
        .animation(DS.motion(reduceMotion), value: step == .pages)
    }

    // MARK: - Setup steps (static chrome, sliding content)

    private var setupFlow: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Progress bar — static; only its fill animates.
            HStack(spacing: 6) {
                ForEach(1...totalSteps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(index <= stepNumber ? DS.Palette.accent : DS.Palette.elevated)
                        .frame(height: 3)
                }
            }
            .animation(DS.motion(reduceMotion), value: stepNumber)
            .animation(DS.motion(reduceMotion), value: totalSteps)
            .padding(.bottom, DS.Space.xl)

            // Step content — the only part that slides.
            ZStack(alignment: .top) {
                switch step {
                case .permissions:
                    PermissionSetupView(mode: .onboarding)
                        .transition(stepTransition)
                case .apps:
                    MockAppSelectionView(mode: .onboarding)
                        .transition(stepTransition)
                case .schedule:
                    ScheduleSetupView(mode: .onboarding)
                        .transition(stepTransition)
                case .anchor:
                    MockAnchorSetupView(mode: .onboarding)
                        .transition(stepTransition)
                case .pages:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()
            .animation(DS.motion(reduceMotion), value: step)

            // Continue button — static; only its label and enabled state change.
            PrimaryButton(title: continueTitle, isEnabled: continueEnabled) {
                advance()
            }
            .padding(.top, DS.Space.m)
        }
        .padding(DS.Space.l)
    }

    private var stepTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
    }

    private var stepNumber: Int {
        switch step {
        case .pages, .permissions: return 1
        case .apps: return 2
        case .schedule: return 3
        case .anchor: return 4
        }
    }

    private var totalSteps: Int {
        state.anchorModeEnabled ? 4 : 3
    }

    private var isLastStep: Bool {
        step == .anchor || (step == .schedule && !state.anchorModeEnabled)
    }

    private var continueTitle: String {
        isLastStep ? "Finish setup" : "Continue"
    }

    private var continueEnabled: Bool {
        switch step {
        case .apps: return !state.selectedTargetIDs.isEmpty
        case .anchor: return state.anchorConfigured
        default: return true
        }
    }

    private func advance() {
        switch step {
        case .pages:
            move(to: .permissions)
        case .permissions:
            move(to: .apps)
        case .apps:
            move(to: .schedule)
        case .schedule:
            if state.anchorModeEnabled {
                move(to: .anchor)
            } else {
                state.completeOnboarding()
            }
        case .anchor:
            state.completeOnboarding()
        }
    }

    private func move(to next: Step) {
        withAnimation(DS.motion(reduceMotion)) {
            step = next
        }
    }
}

// MARK: - Four intro pages

/// Header, page dots, and button are static; only the page content slides.
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
            // Static header
            HStack {
                Text("SleepFuel")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
                Text(String(format: "%02d / %02d", index + 1, pages.count))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(DS.motion(reduceMotion), value: index)
            }
            .padding(.bottom, DS.Space.xl)

            // Sliding page content
            ZStack(alignment: .topLeading) {
                pageContent(pages[index])
                    .id(index)
                    .transition(pageTransition)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .clipped()
            .animation(DS.motion(reduceMotion), value: index)

            // Static dots
            HStack(spacing: 6) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == index ? DS.Palette.accent : DS.Palette.elevated)
                        .frame(width: i == index ? 20 : 6, height: 6)
                }
            }
            .animation(DS.motion(reduceMotion), value: index)
            .padding(.bottom, DS.Space.l)

            // Static button
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
    }

    private var pageTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
    }

    private func pageContent(_ page: Page) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Image(systemName: page.symbol)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(DS.Palette.accent)
                .padding(.bottom, DS.Space.l)

            Text(page.headline)
                .font(DS.Fonts.title)
                .foregroundStyle(DS.Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, DS.Space.m)

            Text(page.body)
                .font(.system(size: 16))
                .foregroundStyle(DS.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
