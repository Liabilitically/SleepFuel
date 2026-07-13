import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var sleepDurationHours: Double {
        TimeFormat.sleepDuration(bedtime: state.bedtime, wakeTime: state.wakeTime)
    }

    private var timeToSleep: (hours: Int, minutes: Int) {
        let cal = Calendar.current
        let now = currentTime
        let today = cal.dateComponents([.year, .month, .day], from: now)
        let bedtimeToday = cal.date(
            bySettingHour: cal.component(.hour, from: state.bedtime),
            minute: cal.component(.minute, from: state.bedtime),
            second: 0,
            of: cal.date(from: today) ?? now
        ) ?? now

        let targetTime = bedtimeToday < now
            ? cal.date(byAdding: .day, value: 1, to: bedtimeToday) ?? bedtimeToday
            : bedtimeToday

        let diff = targetTime.timeIntervalSince(now)
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60

        return (hours, minutes)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            ScrollView {
                VStack(spacing: DS.Space.l) {
                    header

                    VStack(spacing: DS.Space.l) {
                        FuelBatteryView(
                            fuelMinutes: state.todayAllowance,
                            capMinutes: state.allowanceCap
                        )
                        .frame(maxWidth: .infinity)
                        .padding(DS.Space.l)
                        .dsCard()

                        timeToSleepCard

                        tonightsSleepCard

                        blockedAppsCard

                        startSleepModeCard
                    }
                    .padding(DS.Space.l)
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("SleepFuel")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Today's fuel")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.l)
    }

    private var timeToSleepCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Time to sleep")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DS.Palette.textTertiary)
                .textCase(.uppercase)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(timeToSleep.hours)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Palette.accent)
                    .monospacedDigit()

                Text("h")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textSecondary)

                Text("\(timeToSleep.minutes)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Palette.accent)
                    .monospacedDigit()

                Text("m")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .dsCard()
    }

    private var tonightsSleepCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            Text("Tonight's sleep")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DS.Palette.textTertiary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: DS.Space.s) {
                StatusRow(
                    label: "Bedtime",
                    value: TimeFormat.clock(state.bedtime)
                )
                StatusRow(
                    label: "Wake time",
                    value: TimeFormat.clock(state.wakeTime)
                )
                StatusRow(
                    label: "Sleep window",
                    value: String(format: "%.1f h", sleepDurationHours)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .dsCard()
    }

    private var blockedAppsCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("Apps blocked tonight")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DS.Palette.textTertiary)
                .textCase(.uppercase)

            Text("\(state.blockedAppIDs.count) apps")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DS.Palette.textPrimary)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .dsCard()
    }

    private var startSleepModeCard: some View {
        Button {
        } label: {
            Text("Start sleep mode")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(DS.Palette.accent)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
