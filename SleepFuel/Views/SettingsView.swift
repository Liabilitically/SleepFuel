import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showBedtimeEditor = false
    @State private var showWakeTimeEditor = false
    @State private var showAllowanceEditor = false

    private var sleepDurationHours: Double {
        TimeFormat.sleepDuration(bedtime: state.bedtime, wakeTime: state.wakeTime)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.l) {
                    header

                    VStack(spacing: 0) {
                        SectionHeader(title: "Sleep")
                            .padding(DS.Space.m)

                        VStack(spacing: 0) {
                            settingRow(
                                label: "Bed time",
                                value: TimeFormat.clock(state.bedtime),
                                action: { showBedtimeEditor = true }
                            )

                            Divider()
                                .background(DS.Palette.border)
                                .padding(.horizontal, DS.Space.m)

                            settingRow(
                                label: "Wake time",
                                value: TimeFormat.clock(state.wakeTime),
                                action: { showWakeTimeEditor = true }
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
                            action: { showAllowanceEditor = true }
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
                .padding(.bottom, 80)
            }

            if showBedtimeEditor {
                bedtimeEditorOverlay
            }

            if showWakeTimeEditor {
                wakeTimeEditorOverlay
            }

            if showAllowanceEditor {
                allowanceEditorOverlay
            }
        }
    }

    private var header: some View {
        Text("Settings")
            .font(DS.Fonts.title)
            .foregroundStyle(DS.Palette.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func settingRow(
        label: String,
        value: String,
        action: @escaping () -> Void,
        selectable: Bool = true
    ) -> some View {
        Button(action: action) {
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

    private var bedtimeEditorOverlay: some View {
        @Bindable var state = state
        return editorOverlay(title: "Bed time", dismiss: { showBedtimeEditor = false }) {
            DatePicker(
                "Bed time",
                selection: $state.bedtime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .frame(height: 150)
        }
    }

    private var wakeTimeEditorOverlay: some View {
        @Bindable var state = state
        return editorOverlay(title: "Wake time", dismiss: { showWakeTimeEditor = false }) {
            DatePicker(
                "Wake time",
                selection: $state.wakeTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .frame(height: 150)
        }
    }

    private var allowanceEditorOverlay: some View {
        editorOverlay(title: "Time each day", dismiss: { showAllowanceEditor = false }) {
            VStack(spacing: DS.Space.l) {
                Text("\(state.allowanceCap)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Palette.accent)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Slider(
                    value: Binding(
                        get: { Double(state.allowanceCap) },
                        set: { state.allowanceCap = Int($0) }
                    ),
                    in: 30...300,
                    step: 10
                )
                .tint(DS.Palette.accent)
            }
            .padding(DS.Space.l)
        }
    }

    private func editorOverlay<Content: View>(
        title: String,
        dismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Spacer()

                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DS.Palette.textSecondary)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(DS.Space.l)

            Divider()
                .background(DS.Palette.border)

            content()

            Spacer()

            PrimaryButton(title: "Done") {
                withAnimation(DS.motion(reduceMotion)) {
                    dismiss()
                }
            }
            .padding(DS.Space.l)
        }
        .background(DS.Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
        )
        .padding(DS.Space.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color.black.opacity(0.4).ignoresSafeArea())
    }
}
