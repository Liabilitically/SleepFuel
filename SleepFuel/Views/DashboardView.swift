import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Space.m) {
                fuelCard
                tonightCard
                blockedAppsCard
                if let report = state.lastReport {
                    lastNightCard(report)
                }
                if !state.isPro {
                    proUpsellCard
                }
            }
            .padding(DS.Space.m)
        }
        .background(DS.Palette.obsidian)
        .navigationTitle("SleepFuel")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    state.showHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(DS.Palette.textSecondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    state.path.append(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(DS.Palette.textSecondary)
                }
            }
        }
        .toolbarBackground(DS.Palette.obsidian, for: .navigationBar)
    }

    // MARK: - Fuel gauge card

    private var fuelCard: some View {
        VStack(spacing: DS.Space.m) {
            HStack {
                TagView(text: "Today")
                Spacer()
                TagView(text: state.sessionState.label, color: stateColor)
            }

            FuelBatteryView(fuelMinutes: state.availableFuel, capMinutes: state.dailyFuelCap)
                .padding(.vertical, DS.Space.s)

            Text("Fuel available today · cap \(TimeFormat.hoursMinutes(state.dailyFuelCap)) · \(state.fuelMode.title) mode")
                .font(.system(size: 13))
                .foregroundStyle(DS.Palette.textTertiary)
        }
        .padding(DS.Space.m)
        .frame(maxWidth: .infinity)
        .dsCard()
    }

    private var stateColor: Color {
        switch state.sessionState {
        case .notArmed: return DS.Palette.textSecondary
        case .armed: return DS.Palette.accent
        case .active: return DS.Palette.accent
        case .completed: return DS.Palette.success
        case .failed: return DS.Palette.destructive
        }
    }

    // MARK: - Tonight card

    private var tonightCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            HStack {
                SectionHeader(title: "Tonight")
                if state.anchorModeEnabled {
                    TagView(text: "Anchor", color: DS.Palette.accent)
                }
            }

            HStack(alignment: .firstTextBaseline) {
                Text(state.sleepWindowLabel)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(DS.Palette.textPrimary)
                Spacer()
                Text(TimeFormat.hoursMinutes(state.scheduledWindowMinutes))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DS.Palette.textSecondary)
                    .monospacedDigit()
            }

            Text("Earns up to \(potentialFuel) min of fuel at \(state.fuelMode.title.lowercased()) rate")
                .font(.system(size: 13))
                .foregroundStyle(DS.Palette.textTertiary)

            switch state.sessionState {
            case .armed:
                VStack(spacing: DS.Space.s) {
                    PrimaryButton(title: "Start sleep session") {
                        state.startSession()
                    }
                    Button("Disarm") {
                        withAnimation(DS.motion(reduceMotion)) {
                            state.disarm()
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DS.Palette.textTertiary)
                }
            default:
                PrimaryButton(title: "Arm tonight") {
                    withAnimation(DS.motion(reduceMotion)) {
                        state.armTonight()
                    }
                }
            }
        }
        .padding(DS.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsCard()
    }

    private var potentialFuel: Int {
        FuelEngine.fuelMinutes(
            protectedMinutes: state.scheduledWindowMinutes,
            mode: state.fuelMode,
            cap: state.dailyFuelCap
        )
    }

    // MARK: - Blocked apps card

    private var blockedAppsCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            HStack {
                SectionHeader(title: "Blocked apps")
                Text("\(state.selectedTargets.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DS.Palette.textSecondary)
                    .monospacedDigit()
            }

            if state.selectedTargets.isEmpty {
                Text("No apps selected. Nothing is shielded tonight.")
                    .font(.system(size: 14))
                    .foregroundStyle(DS.Palette.textTertiary)
            } else {
                HStack(spacing: DS.Space.s) {
                    ForEach(state.selectedTargets.prefix(6)) { target in
                        IconBadge(symbol: target.symbol, size: 40, tint: DS.Palette.textSecondary)
                    }
                    if state.selectedTargets.count > 6 {
                        Text("+\(state.selectedTargets.count - 6)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DS.Palette.textTertiary)
                            .frame(width: 40, height: 40)
                            .background(DS.Palette.elevated)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
                    }
                    Spacer()
                }
            }

            SecondaryButton(title: "Edit apps") {
                state.path.append(.editApps)
            }
        }
        .padding(DS.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsCard()
    }

    // MARK: - Last night card

    private func lastNightCard(_ report: NightRecord) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            HStack {
                SectionHeader(title: "Last night")
                Text(report.grade)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Palette.accent)
            }
            PenaltyBreakdownView(record: report)
        }
        .padding(DS.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dsCard()
    }

    // MARK: - Pro upsell

    private var proUpsellCard: some View {
        Button {
            state.showPaywall = true
        } label: {
            HStack(spacing: DS.Space.m) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(DS.Palette.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("SleepFuel Pro")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DS.Palette.textPrimary)
                    Text("Unlimited apps, strict mode, anchor enforcement")
                        .font(.system(size: 12))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DS.Palette.textTertiary)
            }
            .padding(DS.Space.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .dsCard(elevated: true)
    }
}
