import SwiftUI

struct HistoryView: View {
    @Environment(AppState.self) private var state

    private var nights: [NightRecord] {
        Array(state.history.prefix(7))
    }

    private var maxFuel: Int {
        max(nights.map(\.fuelEarned).max() ?? 1, 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Space.m) {
                    summaryTiles

                    VStack(alignment: .leading, spacing: DS.Space.m) {
                        SectionHeader(title: "Last 7 nights")
                        if nights.isEmpty {
                            Text("No nights recorded yet. Arm tonight to start.")
                                .font(.system(size: 14))
                                .foregroundStyle(DS.Palette.textTertiary)
                        } else {
                            VStack(spacing: DS.Space.m) {
                                ForEach(nights) { nightRow($0) }
                            }
                        }
                    }
                    .padding(DS.Space.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .dsCard()
                }
                .padding(DS.Space.m)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Palette.obsidian.ignoresSafeArea())
    }

    // Slides in from the left, so the dismiss control sits top-left
    // and sends the panel back the way it came.
    private var header: some View {
        ZStack {
            Text("History")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DS.Palette.textPrimary)

            HStack {
                Button {
                    state.showHistory = false
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DS.Palette.textSecondary)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
                Spacer()
            }
        }
        .padding(.horizontal, DS.Space.s)
        .frame(height: 48)
    }

    // MARK: - Summary

    private var summaryTiles: some View {
        let avgProtected = nights.isEmpty
            ? 0
            : nights.reduce(0) { $0 + $1.protectedMinutes } / nights.count
        let unlocks = nights.reduce(0) { $0 + $1.emergencyUnlockCount }
        let missedAnchors = nights.filter(\.missedAnchor).count

        return VStack(spacing: DS.Space.s) {
            HStack(spacing: DS.Space.s) {
                StatTile(
                    value: TimeFormat.hoursMinutes(avgProtected),
                    label: "Avg protected sleep"
                )
                StatTile(
                    value: "\(nights.reduce(0) { $0 + $1.fuelEarned }) min",
                    label: "Fuel earned this week"
                )
            }
            HStack(spacing: DS.Space.s) {
                StatTile(
                    value: "\(unlocks)",
                    label: "Emergency unlocks"
                )
                StatTile(
                    value: "\(missedAnchors)",
                    label: "Missed anchors"
                )
            }
        }
    }

    // MARK: - Night row

    private func nightRow(_ night: NightRecord) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack {
                Text(TimeFormat.weekdayShort(night.date))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DS.Palette.textSecondary)
                    .frame(width: 40, alignment: .leading)

                Text(TimeFormat.hoursMinutes(night.protectedMinutes))
                    .font(.system(size: 13))
                    .foregroundStyle(DS.Palette.textTertiary)
                    .monospacedDigit()

                Spacer()

                if night.emergencyUnlockCount > 0 {
                    Image(systemName: "bolt.slash.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(DS.Palette.accent)
                }
                if night.missedAnchor {
                    Image(systemName: "qrcode")
                        .font(.system(size: 11))
                        .foregroundStyle(DS.Palette.accent)
                }

                Text(night.grade)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(night.grade.hasPrefix("A") ? DS.Palette.success : DS.Palette.textSecondary)
                    .frame(width: 28, alignment: .trailing)
            }

            // Fuel bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(DS.Palette.elevated)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(DS.Palette.accent)
                        .frame(width: geo.size.width * CGFloat(night.fuelEarned) / CGFloat(maxFuel))
                }
            }
            .frame(height: 6)

            Text("\(night.fuelEarned) min fuel")
                .font(.system(size: 11))
                .foregroundStyle(DS.Palette.textTertiary)
                .monospacedDigit()
        }
    }
}
