import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showBedtimeEditor = false
    @State private var showWakeTimeEditor = false
    @State private var showAllowanceEditor = false
    @State private var showAppsEditor = false
    @State private var showStrictnessEditor = false

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
                        SectionHeader(title: "Sleep Schedule")
                            .padding(DS.Space.m)

                        VStack(spacing: 0) {
                            settingRow(
                                label: "Bedtime",
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
                                label: "Sleep window",
                                value: String(format: "%.1f h", sleepDurationHours),
                                action: {},
                                selectable: false
                            )
                        }
                    }
                    .dsCard()

                    VStack(spacing: 0) {
                        SectionHeader(title: "Daily Allowance")
                            .padding(DS.Space.m)

                        settingRow(
                            label: "Daily cap",
                            value: "\(state.allowanceCap) min",
                            action: { showAllowanceEditor = true }
                        )
                    }
                    .dsCard()

                    VStack(spacing: 0) {
                        SectionHeader(title: "App Blocking")
                            .padding(DS.Space.m)

                        VStack(spacing: 0) {
                            settingRow(
                                label: "Blocked apps",
                                value: "\(state.blockedAppIDs.count) apps",
                                action: { showAppsEditor = true }
                            )

                            Divider()
                                .background(DS.Palette.border)
                                .padding(.horizontal, DS.Space.m)

                            settingRow(
                                label: "Blocking level",
                                value: state.blockingStrictness.capitalized,
                                action: { showStrictnessEditor = true }
                            )
                        }
                    }
                    .dsCard()

                    VStack(spacing: DS.Space.m) {
                        SecondaryButton(title: "Reset Onboarding") {
                            state.resetOnboarding()
                        }

                        Text("This will clear your setup and restart the onboarding flow. Use this for testing.")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.Palette.textTertiary)
                    }
                    .padding(.top, DS.Space.l)
                }
                .padding(DS.Space.l)
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

            if showAppsEditor {
                appsEditorOverlay
            }

            if showStrictnessEditor {
                strictnessEditorOverlay
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("SleepFuel")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)
        }
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
        VStack {
            HStack {
                Text("Edit Bedtime")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Spacer()

                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        showBedtimeEditor = false
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

            DatePicker(
                "Bedtime",
                selection: $state.bedtime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .frame(height: 150)

            Spacer()

            PrimaryButton(title: "Done") {
                withAnimation(DS.motion(reduceMotion)) {
                    showBedtimeEditor = false
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

    private var wakeTimeEditorOverlay: some View {
        VStack {
            HStack {
                Text("Edit Wake Time")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Spacer()

                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        showWakeTimeEditor = false
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

            DatePicker(
                "Wake Time",
                selection: $state.wakeTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .frame(height: 150)

            Spacer()

            PrimaryButton(title: "Done") {
                withAnimation(DS.motion(reduceMotion)) {
                    showWakeTimeEditor = false
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

    private var allowanceEditorOverlay: some View {
        VStack {
            HStack {
                Text("Edit Daily Allowance")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Spacer()

                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        showAllowanceEditor = false
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

            Spacer()

            PrimaryButton(title: "Done") {
                withAnimation(DS.motion(reduceMotion)) {
                    showAllowanceEditor = false
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

    private var appsEditorOverlay: some View {
        VStack {
            HStack {
                Text("Edit Blocked Apps")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Spacer()

                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        showAppsEditor = false
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

            ScrollView {
                VStack(spacing: DS.Space.m) {
                    ForEach(Array(allBlockedAppCategories.keys.sorted()), id: \.self) { category in
                        VStack(alignment: .leading, spacing: DS.Space.s) {
                            Text(category)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(DS.Palette.textTertiary)
                                .textCase(.uppercase)

                            if let apps = allBlockedAppCategories[category] {
                                VStack(spacing: DS.Space.s) {
                                    ForEach(apps, id: \.self) { app in
                                        appToggleRow(app)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(DS.Space.l)
            }

            Spacer()

            PrimaryButton(title: "Done") {
                withAnimation(DS.motion(reduceMotion)) {
                    showAppsEditor = false
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

    private func appToggleRow(_ app: String) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                if state.blockedAppIDs.contains(app) {
                    state.blockedAppIDs.remove(app)
                } else {
                    state.blockedAppIDs.insert(app)
                }
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                CheckBox(isOn: state.blockedAppIDs.contains(app))
                Text(app)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var strictnessEditorOverlay: some View {
        VStack {
            HStack {
                Text("Edit Blocking Level")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Spacer()

                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        showStrictnessEditor = false
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

            ScrollView {
                VStack(spacing: DS.Space.m) {
                    ForEach(BlockingStrictness.allCases, id: \.id) { option in
                        strictnessToggleRow(option)
                    }
                }
                .padding(DS.Space.l)
            }

            Spacer()

            PrimaryButton(title: "Done") {
                withAnimation(DS.motion(reduceMotion)) {
                    showStrictnessEditor = false
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

    private func strictnessToggleRow(_ option: BlockingStrictness) -> some View {
        Button {
            withAnimation(DS.motion(reduceMotion)) {
                state.blockingStrictness = option.rawValue
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                ZStack {
                    Circle()
                        .fill(
                            state.blockingStrictness == option.rawValue
                                ? DS.Palette.accent
                                : DS.Palette.elevated
                        )
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    state.blockingStrictness == option.rawValue
                                        ? DS.Palette.accent
                                        : DS.Palette.border,
                                    lineWidth: 1
                                )
                        )

                    if state.blockingStrictness == option.rawValue {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }

                VStack(alignment: .leading, spacing: DS.Space.s) {
                    Text(option.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DS.Palette.textPrimary)
                    Text(option.detail)
                        .font(.system(size: 13))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
