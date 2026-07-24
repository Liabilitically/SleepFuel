import SwiftUI
import Combine

struct HomeView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var minutesToBedtime: Int {
        let cal = Calendar.current
        let now = currentTime
        let today = cal.dateComponents([.year, .month, .day], from: now)
        let bedtimeToday = cal.date(
            bySettingHour: cal.component(.hour, from: state.bedtime),
            minute: cal.component(.minute, from: state.bedtime),
            second: 0,
            of: cal.date(from: today) ?? now
        ) ?? now

        let target = bedtimeToday < now
            ? cal.date(byAdding: .day, value: 1, to: bedtimeToday) ?? bedtimeToday
            : bedtimeToday

        return Int(target.timeIntervalSince(now)) / 60
    }

    private var bedtimeCountdown: String {
        TimeFormat.hoursMinutes(minutesToBedtime)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            ScrollView {
                VStack(spacing: DS.Space.l) {
                    header

                    // Mock of the "5 minutes to bed" notification
                    if minutesToBedtime <= 5 {
                        bedtimeSoonBanner
                    }

                    VStack(spacing: DS.Space.m) {
                        FuelBatteryView(
                            fuelMinutes: state.todayAllowance,
                            capMinutes: state.allowanceCap
                        )
                        .frame(maxWidth: .infinity)
                        .padding(DS.Space.l)
                        .dsCard()

                        sleepCard

                        PrimaryButton(title: "Start sleep mode") {
                            state.startNightManually()
                        }
                    }
                }
                .padding(DS.Space.l)
                .padding(.bottom, 80)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DS.Space.s) {
                Text("Today")
                    .font(DS.Fonts.title)
                    .foregroundStyle(DS.Palette.textPrimary)

                Text("Time left on your phone")
                    .font(.system(size: 15))
                    .foregroundStyle(DS.Palette.textSecondary)
            }

            Spacer()

            Button {
                withAnimation(DS.motion(reduceMotion)) {
                    state.selectedBottomTab = .history
                }
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .liquidGlass(in: Circle())
            .accessibilityLabel("History")
        }
    }

    private var sleepCard: some View {
        VStack(alignment: .leading, spacing: DS.Space.m) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Bed in")
                    .font(.system(size: 15))
                    .foregroundStyle(DS.Palette.textSecondary)

                Text(bedtimeCountdown)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Palette.accent)
                    .monospacedDigit()
            }

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(DS.Palette.textTertiary)
                    Text(TimeFormat.clock(state.bedtime))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DS.Palette.textPrimary)
                        .monospacedDigit()
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(DS.Palette.textTertiary)
                    Text(TimeFormat.clock(state.wakeTime))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DS.Palette.textPrimary)
                        .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Space.m)
        .dsCard()
    }

    private var bedtimeSoonBanner: some View {
        HStack(spacing: DS.Space.m) {
            Image(systemName: "bell.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DS.Palette.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Bed time soon")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Text("Sleep mode starts in \(max(minutesToBedtime, 0)) min. Time to put your phone down.")
                    .font(.system(size: 13))
                    .foregroundStyle(DS.Palette.textSecondary)
            }

            Spacer()
        }
        .padding(DS.Space.m)
        .dsCard(elevated: true)
    }
}
