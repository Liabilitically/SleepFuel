import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var sleepDurationHours: Double {
        TimeFormat.sleepDuration(bedtime: state.bedtime, wakeTime: state.wakeTime)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            switch state.settingsEditor {
            case .bedtime:
                TimeEditorScreen(title: "Bed time", initial: state.bedtime) { newValue in
                    state.bedtime = newValue
                    state.settingsEditor = nil
                }
                .transition(.opacity)
            case .wakeTime:
                TimeEditorScreen(title: "Wake time", initial: state.wakeTime) { newValue in
                    state.wakeTime = newValue
                    state.settingsEditor = nil
                }
                .transition(.opacity)
            case .allowance:
                AllowanceEditorScreen(initial: state.allowanceCap) { newValue in
                    state.allowanceCap = newValue
                    state.settingsEditor = nil
                }
                .transition(.opacity)
            case nil:
                settingsList
                    .transition(.opacity)
            }
        }
        .animation(DS.motion(reduceMotion), value: state.settingsEditor)
    }

    private var settingsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Space.l) {
                Text("Settings")
                    .font(DS.Fonts.title)
                    .foregroundStyle(DS.Palette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                    SectionHeader(title: "Sleep")
                        .padding(DS.Space.m)

                    VStack(spacing: 0) {
                        settingRow(
                            label: "Bed time",
                            value: TimeFormat.clock(state.bedtime),
                            action: { state.settingsEditor = .bedtime }
                        )

                        Divider()
                            .background(DS.Palette.border)
                            .padding(.horizontal, DS.Space.m)

                        settingRow(
                            label: "Wake time",
                            value: TimeFormat.clock(state.wakeTime),
                            action: { state.settingsEditor = .wakeTime }
                        )

                        Divider()
                            .background(DS.Palette.border)
                            .padding(.horizontal, DS.Space.m)

                        settingRow(
                            label: "Sleep",
                            value: String(format: "%.1f h", sleepDurationHours),
                            action: {},
                            selectable: false
                        )
                    }
                }
                .dsCard()

                VStack(spacing: 0) {
                    SectionHeader(title: "Screen time")
                        .padding(DS.Space.m)

                    settingRow(
                        label: "Time each day",
                        value: "\(state.allowanceCap) min",
                        action: { state.settingsEditor = .allowance }
                    )
                }
                .dsCard()

                VStack(spacing: DS.Space.m) {
                    SecondaryButton(title: "Reset Onboarding") {
                        state.resetOnboarding()
                    }

                    Text("Clears your setup and starts over. For testing.")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                }
                .padding(.top, DS.Space.l)
            }
            .padding(DS.Space.l)
            .padding(.bottom, 100)
        }
    }

    private func settingRow(
        label: String,
        value: String,
        action: @escaping () -> Void,
        selectable: Bool = true
    ) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                action()
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Palette.textPrimary)

                Spacer()

                HStack(spacing: DS.Space.s) {
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(DS.Palette.textSecondary)

                    if selectable {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DS.Palette.textTertiary)
                    }
                }
            }
            .padding(DS.Space.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!selectable)
    }
}

// MARK: - Editor sub-screens
// Full screens, not modals: the bottom nav shows a back chevron while
// one is open. Save commits; going back discards.

private struct TimeEditorScreen: View {
    let title: String
    let onSave: (Date) -> Void
    @State private var draft: Date

    init(title: String, initial: Date, onSave: @escaping (Date) -> Void) {
        self.title = title
        self.onSave = onSave
        _draft = State(initialValue: initial)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text(title)
                .font(DS.Fonts.title)
                .foregroundStyle(DS.Palette.textPrimary)

            DatePicker(
                "",
                selection: $draft,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)

            Spacer()

            PrimaryButton(title: "Save") {
                onSave(draft)
            }
            .padding(.bottom, 88)
        }
        .padding(DS.Space.l)
    }
}

private struct AllowanceEditorScreen: View {
    let onSave: (Int) -> Void
    @State private var draft: Int

    init(initial: Int, onSave: @escaping (Int) -> Void) {
        self.onSave = onSave
        _draft = State(initialValue: initial)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.l) {
            Text("Time each day")
                .font(DS.Fonts.title)
                .foregroundStyle(DS.Palette.textPrimary)

            VStack(spacing: DS.Space.l) {
                Text("\(draft)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Palette.accent)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Slider(
                    value: Binding(
                        get: { Double(draft) },
                        set: { draft = Int($0) }
                    ),
                    in: 30...300,
                    step: 10
                )
                .tint(DS.Palette.accent)
            }
            .frame(maxWidth: .infinity)
            .padding(DS.Space.l)
            .dsCard()

            Spacer()

            PrimaryButton(title: "Save") {
                onSave(draft)
            }
            .padding(.bottom, 88)
        }
        .padding(DS.Space.l)
    }
}
