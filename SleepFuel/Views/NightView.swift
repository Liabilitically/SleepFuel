import SwiftUI
import Combine

/// Sleep mode. On a real device this lives on the lock screen as a
/// Live Activity; here the whole screen mocks that experience.
/// While this screen is open, tomorrow's time drains — because an open
/// phone during sleep time is exactly what costs allowance.
struct NightView: View {
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var remainingDisplay: String {
        let remaining = max(0, Double(state.allowanceCap) - state.nightDrainedMinutes)
        return String(format: "%.1f", remaining)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            VStack(spacing: DS.Space.l) {
                Spacer()

                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(DS.Palette.accent)

                Text("Sleep mode is on")
                    .font(DS.Fonts.title)
                    .foregroundStyle(DS.Palette.textPrimary)

                Text("Lock your phone to keep your time.")
                    .font(.system(size: 15))
                    .foregroundStyle(DS.Palette.textSecondary)

                // Mock Live Activity — what the lock screen / Dynamic Island shows
                liveActivityCard

                warningCard

                Spacer()

                PrimaryButton(title: "I'm awake") {
                    state.endNight()
                }

                Text("Wakes you up and ends sleep mode.")
                    .font(.system(size: 12))
                    .foregroundStyle(DS.Palette.textTertiary)
            }
            .padding(DS.Space.l)
        }
        .onReceive(tick) { _ in
            state.nightTick(openSeconds: 1)
        }
    }

    private var liveActivityCard: some View {
        VStack(spacing: DS.Space.s) {
            HStack(spacing: DS.Space.m) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(DS.Palette.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tomorrow's time")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DS.Palette.textTertiary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(remainingDisplay)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(DS.Palette.textPrimary)
                            .monospacedDigit()
                            .contentTransition(.numericText())

                        Text("min")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(DS.Palette.textSecondary)
                    }
                }

                Spacer()

                Text("\(TimeFormat.clock(state.bedtime)) – \(TimeFormat.clock(state.wakeTime))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .monospacedDigit()
            }
            .padding(DS.Space.m)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(DS.Palette.border, lineWidth: DS.hairline)
            )
            .animation(DS.motion(reduceMotion), value: remainingDisplay)

            Text("This shows on your lock screen all night.")
                .font(.system(size: 12))
                .foregroundStyle(DS.Palette.textTertiary)
        }
    }

    private var warningCard: some View {
        HStack(spacing: DS.Space.m) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DS.Palette.destructive)

            Text("Your phone is open. Tomorrow's time is going down.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DS.Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(DS.Space.m)
        .dsCard()
    }
}
