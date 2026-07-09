import SwiftUI

struct ScheduleSetupView: View {
    let mode: ScreenMode
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        Group {
            if case .onboarding(let onContinue) = mode {
                OnboardingChrome(
                    step: 2,
                    totalSteps: 4,
                    title: "Protect your sleep window",
                    subtitle: "Every minute inside the window generates fuel. Every breach costs you.",
                    onContinue: onContinue
                ) {
                    ScrollView(showsIndicators: false) {
                        scheduleContent
                    }
                }
            } else {
                ScrollView(showsIndicators: false) {
                    scheduleContent
                        .padding(DS.Space.l)
                }
                .background(DS.Palette.obsidian)
                .navigationTitle("Schedule")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private var scheduleContent: some View {
        @Bindable var state = state

        return VStack(spacing: DS.Space.m) {
            // Window
            VStack(spacing: 0) {
                HStack {
                    Text("Bedtime")
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textSecondary)
                    Spacer()
                    DatePicker("", selection: $state.bedtime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .padding(DS.Space.m)

                Rectangle().fill(DS.Palette.border).frame(height: DS.hairline)

                HStack {
                    Text("Wake time")
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textSecondary)
                    Spacer()
                    DatePicker("", selection: $state.wakeTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .padding(DS.Space.m)

                Rectangle().fill(DS.Palette.border).frame(height: DS.hairline)

                StatusRow(
                    label: "Sleep window",
                    value: TimeFormat.hoursMinutes(state.scheduledWindowMinutes),
                    valueColor: DS.Palette.accent
                )
                .padding(DS.Space.m)
            }
            .dsCard()

            // Repeat days
            VStack(alignment: .leading, spacing: DS.Space.s) {
                SectionHeader(title: "Repeat")
                HStack(spacing: DS.Space.s) {
                    ForEach(0..<7, id: \.self) { day in
                        dayChip(day)
                    }
                }
            }
            .padding(DS.Space.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsCard()

            // Fuel mode
            VStack(alignment: .leading, spacing: DS.Space.s) {
                SectionHeader(title: "Fuel mode")
                ForEach(FuelMode.allCases) { fuelModeRow($0) }
            }
            .padding(DS.Space.m)
            .dsCard()

            // Cap + anchor
            VStack(spacing: 0) {
                HStack {
                    Text("Daily fuel cap")
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textSecondary)
                    Spacer()
                    Text(TimeFormat.hoursMinutes(state.dailyFuelCap))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DS.Palette.textPrimary)
                        .monospacedDigit()
                    Stepper("", value: $state.dailyFuelCap, in: 30...300, step: 15)
                        .labelsHidden()
                }
                .padding(DS.Space.m)

                Rectangle().fill(DS.Palette.border).frame(height: DS.hairline)

                Toggle(isOn: $state.anchorModeEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Anchor mode")
                            .font(.system(size: 15))
                            .foregroundStyle(DS.Palette.textPrimary)
                        Text("Physical checkpoint away from your bed")
                            .font(.system(size: 12))
                            .foregroundStyle(DS.Palette.textTertiary)
                    }
                }
                .tint(DS.Palette.accent)
                .padding(DS.Space.m)
            }
            .dsCard()
        }
        .onChange(of: state.bedtime) { state.save() }
        .onChange(of: state.wakeTime) { state.save() }
        .onChange(of: state.dailyFuelCap) { state.save() }
        .onChange(of: state.anchorModeEnabled) { state.save() }
    }

    private func dayChip(_ day: Int) -> some View {
        let isOn = state.repeatDays.contains(day)
        return Button {
            withAnimation(DS.motion(reduceMotion)) {
                if isOn {
                    state.repeatDays.remove(day)
                } else {
                    state.repeatDays.insert(day)
                }
                state.save()
            }
        } label: {
            Text(dayLabels[day])
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isOn ? .white : DS.Palette.textTertiary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isOn ? DS.Palette.accent : DS.Palette.elevated)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func fuelModeRow(_ modeOption: FuelMode) -> some View {
        let isSelected = state.fuelMode == modeOption
        let locked = modeOption.requiresPro && !state.isPro

        return Button {
            if locked {
                state.showPaywall = true
            } else {
                withAnimation(DS.motion(reduceMotion)) {
                    state.fuelMode = modeOption
                }
                state.save()
            }
        } label: {
            HStack(spacing: DS.Space.m) {
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? DS.Palette.accent : DS.Palette.textTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: DS.Space.s) {
                        Text(modeOption.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(DS.Palette.textPrimary)
                        if locked {
                            ProTag()
                        }
                    }
                    Text(modeOption.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Spacer()

                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(DS.Palette.textTertiary)
                }
            }
            .padding(.vertical, DS.Space.s)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}
