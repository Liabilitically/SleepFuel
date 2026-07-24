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
    @Namespace private var pillNamespace

    var body: some View {
        Group {
            if state.settingsEditor != nil {
                backButton {
                    state.settingsEditor = nil
                }
            } else if state.selectedBottomTab == .history {
                backButton {
                    state.selectedBottomTab = .home
                }
            } else {
                tabBar
            }
        }
        .padding(.bottom, DS.Space.s)
        .animation(DS.motion(reduceMotion), value: state.settingsEditor)
        .animation(DS.motion(reduceMotion), value: state.selectedBottomTab)
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            tabItem(.home)
            tabItem(.settings)
        }
        .padding(4)
        .liquidGlass(in: Capsule())
    }

    private func tabItem(_ tab: BottomTab) -> some View {
        let isActive = state.selectedBottomTab == tab
        return Button {
            withAnimation(DS.motion(reduceMotion)) {
                state.selectedBottomTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(tab.label)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(isActive ? DS.Palette.accent : DS.Palette.textPrimary.opacity(0.8))
            .frame(width: 96, height: 54)
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
        .background {
            if isActive {
                activePill
                    .matchedGeometryEffect(id: "activeTabPill", in: pillNamespace)
            }
        }
    }

    /// The pill that wraps the current page — Liquid Glass on iOS 26.
    @ViewBuilder
    private var activePill: some View {
        if #available(iOS 26.0, *) {
            Color.clear
                .glassEffect(.regular.interactive(), in: Capsule())
        } else {
            Capsule()
                .fill(Color.white.opacity(0.12))
        }
    }

    /// Single back chevron — the navbar's compact mode inside sub-screens.
    private func backButton(_ action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                action()
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DS.Palette.textPrimary)
                .frame(width: 58, height: 58)
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
        .liquidGlass(in: Circle())
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
