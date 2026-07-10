import SwiftUI

struct MockAppSelectionView: View {
    let mode: ScreenMode
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if mode == .onboarding {
                VStack(alignment: .leading, spacing: 0) {
                    OnboardingStepHeader(
                        title: "Choose what drains your night",
                        subtitle: "These stay shielded until you've earned fuel. Pick the ones that actually keep you up."
                    )
                    ScrollView(showsIndicators: false) {
                        selectionContent
                    }
                }
            } else {
                ScrollView(showsIndicators: false) {
                    selectionContent
                        .padding(DS.Space.l)
                }
                .background(DS.Palette.obsidian)
                .navigationTitle("Blocked Apps")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private var selectionContent: some View {
        VStack(spacing: DS.Space.m) {
            if !state.isPro {
                limitBar
            }

            VStack(alignment: .leading, spacing: DS.Space.s) {
                SectionHeader(title: "Apps")
                targetList(MockData.apps)
            }

            VStack(alignment: .leading, spacing: DS.Space.s) {
                SectionHeader(title: "Categories")
                targetList(MockData.categories)
            }
        }
    }

    private var limitBar: some View {
        HStack(spacing: DS.Space.s) {
            Image(systemName: state.atFreeLimit ? "lock.fill" : "checkmark.circle")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(state.atFreeLimit ? DS.Palette.accent : DS.Palette.textTertiary)

            Text("\(state.selectedTargetIDs.count) of \(AppState.freeSelectionLimit) free selections")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DS.Palette.textSecondary)

            Spacer()

            Button("Upgrade") {
                state.showPaywall = true
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(DS.Palette.accent)
        }
        .padding(DS.Space.m)
        .dsCard(elevated: true)
    }

    private func targetList(_ targets: [BlockTarget]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(targets.enumerated()), id: \.element.id) { index, target in
                targetRow(target)
                if index < targets.count - 1 {
                    Rectangle()
                        .fill(DS.Palette.border)
                        .frame(height: DS.hairline)
                        .padding(.leading, 68)
                }
            }
        }
        .dsCard()
    }

    private func targetRow(_ target: BlockTarget) -> some View {
        let isSelected = state.selectedTargetIDs.contains(target.id)

        return Button {
            let allowed = withAnimation(DS.motion(reduceMotion)) {
                state.toggleTarget(target.id)
            }
            if !allowed {
                state.showPaywall = true
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                IconBadge(symbol: target.symbol, tint: isSelected ? DS.Palette.accent : DS.Palette.textTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(target.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DS.Palette.textPrimary)
                    if target.isCategory {
                        Text("Category")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.Palette.textTertiary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isSelected ? DS.Palette.accent : DS.Palette.textTertiary)
            }
            .padding(DS.Space.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
