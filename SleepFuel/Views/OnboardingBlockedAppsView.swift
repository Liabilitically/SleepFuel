import SwiftUI

struct OnboardingBlockedAppsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let categories = allBlockedAppCategories.keys.sorted()

    var body: some View {
        VStack(spacing: DS.Space.l) {
            OnboardingStepHeader(
                title: "Which apps distract you at night?",
                subtitle: "Choose at least one."
            )

            VStack(spacing: DS.Space.m) {
                ForEach(categories, id: \.self) { category in
                    categorySection(category)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func categorySection(_ category: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text(category)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DS.Palette.textTertiary)
                .textCase(.uppercase)

            VStack(spacing: DS.Space.s) {
                if let apps = allBlockedAppCategories[category] {
                    ForEach(apps, id: \.self) { app in
                        appButton(app)
                    }
                }
            }
        }
    }

    private func appButton(_ app: String) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                if state.onboarding.blockedAppIDs.contains(app) {
                    state.onboarding.blockedAppIDs.remove(app)
                } else {
                    state.onboarding.blockedAppIDs.insert(app)
                }
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                CheckBox(isOn: state.onboarding.blockedAppIDs.contains(app))
                Text(app)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
