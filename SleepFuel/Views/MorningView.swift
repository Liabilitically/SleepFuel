import SwiftUI

/// Morning report. On a real device this arrives as a notification
/// when the sleep window ends; here it's the first screen of the day.
struct MorningView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var widgetAdded = false

    private var sleepHoursDisplay: String {
        guard let night = state.lastNight else { return "0" }
        return String(format: "%.1f", night.actualSleepHours)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            VStack(spacing: DS.Space.l) {
                Spacer()

                Image(systemName: "sun.max.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(DS.Palette.accent)

                Text("Good morning")
                    .font(DS.Fonts.title)
                    .foregroundStyle(DS.Palette.textPrimary)

                Text("You slept \(sleepHoursDisplay) hours.")
                    .font(.system(size: 15))
                    .foregroundStyle(DS.Palette.textSecondary)

                // Today's earned time
                VStack(spacing: DS.Space.s) {
                    Text("Your time today")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.Palette.textTertiary)
                        .textCase(.uppercase)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(state.todayAllowance)")
                            .font(DS.Fonts.display)
                            .foregroundStyle(DS.Palette.textPrimary)
                            .monospacedDigit()

                        Text("min")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(DS.Palette.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(DS.Space.l)
                .dsCard()

                widgetCard

                Spacer()

                PrimaryButton(title: "Start my day") {
                    state.startDay()
                }
            }
            .padding(DS.Space.l)
        }
    }

    private var widgetCard: some View {
        HStack(spacing: DS.Space.m) {
            Image(systemName: widgetAdded ? "checkmark.circle.fill" : "lock.iphone")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(widgetAdded ? DS.Palette.success : DS.Palette.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(widgetAdded ? "Widget added" : "See your time all day")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DS.Palette.textPrimary)

                Text(widgetAdded
                     ? "Your time now shows on your lock screen."
                     : "Add the lock screen widget.")
                    .font(.system(size: 13))
                    .foregroundStyle(DS.Palette.textTertiary)
            }

            Spacer()

            if !widgetAdded {
                Button {
                    withAnimation(DS.motion(reduceMotion)) {
                        widgetAdded = true
                    }
                } label: {
                    Text("Add")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, DS.Space.m)
                        .padding(.vertical, DS.Space.s)
                        .background(DS.Palette.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(DS.Space.m)
        .dsCard()
    }
}
