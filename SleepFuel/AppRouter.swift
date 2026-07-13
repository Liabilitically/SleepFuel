import SwiftUI

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

    var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DS.Palette.obsidian)
    }
}

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
                            .font(.system(size: 20, weight: .semibold))
                        Text(tab.label)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(state.selectedBottomTab == tab ? DS.Palette.accent : DS.Palette.textTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                }
            }
        }
        .background(DS.Palette.surface)
        .overlay(
            Rectangle()
                .fill(DS.Palette.border)
                .frame(height: DS.hairline),
            alignment: .top
        )
    }
}
