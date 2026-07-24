import SwiftUI
import Combine

struct RootView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            switch state.route {
            case .launch:
                LaunchView()
                    .transition(.opacity)
            case .onboarding:
                OnboardingContainerView()
                    .transition(.opacity)
            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(DS.motion(reduceMotion), value: state.route)
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Charges screen time and syncs the sleep window with the clock.
    private let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            switch state.phase {
            case .night:
                NightView()
                    .transition(.opacity)
            case .morning:
                MorningView()
                    .transition(.opacity)
            case .day:
                ZStack(alignment: .bottom) {
                    Group {
                        switch state.selectedBottomTab {
                        case .home:
                            HomeView()
                        case .history:
                            HistoryView()
                        case .settings:
                            SettingsView()
                        }
                    }

                    BottomTabBar()
                }
                .transition(.opacity)

                if state.isBlocked {
                    BlockedView()
                        .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Palette.obsidian)
        .animation(DS.motion(reduceMotion), value: state.phase)
        .animation(DS.motion(reduceMotion), value: state.isBlocked)
        .onReceive(minuteTimer) { _ in
            state.minuteTick()
        }
    }
}

// MARK: - Liquid Glass tab bar

struct BottomTabBar: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(BottomTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        state.selectedBottomTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 19, weight: .semibold))
                        Text(tab.label)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(
                        state.selectedBottomTab == tab
                            ? DS.Palette.accent
                            : DS.Palette.textPrimary.opacity(0.8)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, DS.Space.s)
        .liquidGlass(in: Capsule())
        .padding(.horizontal, DS.Space.xl)
        .padding(.bottom, DS.Space.s)
    }
}

extension View {
    /// iOS 26 Liquid Glass, with a material fallback on older systems.
    @ViewBuilder
    func liquidGlass(in shape: some InsettableShape) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
        }
    }
}
