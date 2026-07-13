import SwiftUI

struct HistoryView: View {
    @Environment(AppState.self) private var state

    private var nights: [NightRecord] {
        Array(state.history.prefix(7))
    }

    private var maxAllowance: Int {
        max(nights.map(\.allowanceEarned).max() ?? 1, 1)
    }

    var body: some View {
        ZStack {
            DS.Palette.obsidian.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DS.Space.l) {
                    header

                    if nights.isEmpty {
                        emptyState
                    } else {
                        summaryTiles
                        nightsList
                    }
                }
                .padding(DS.Space.l)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            Text("SleepFuel")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Last 7 nights")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Palette.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: DS.Space.m) {
            Text("No nights recorded yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DS.Palette.textPrimary)

            Text("Start your first sleep session to see your history.")
                .font(.system(size: 14))
                .foregroundStyle(DS.Palette.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Space.l)
        .dsCard()
    }

    private var summaryTiles: some View {
        let avgSleep = nights.isEmpty
            ? 0.0
            : nights.reduce(0) { $0 + $1.actualSleepHours } / Double(nights.count)
        let totalAllowance = nights.reduce(0) { $0 + $1.allowanceEarned }

        return VStack(spacing: DS.Space.s) {
            HStack(spacing: DS.Space.s) {
                StatTile(
                    value: String(format: "%.1f", avgSleep),
                    label: "Average sleep"
                )
                StatTile(
                    value: "\(totalAllowance)",
                    label: "Total fuel earned"
                )
            }
        }
    }

    private var nightsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Sleep records")
                .padding(.bottom, DS.Space.m)

            VStack(spacing: DS.Space.m) {
                ForEach(nights) { night in
                    nightRow(night)
                }
            }
        }
        .padding(DS.Space.m)
        .dsCard()
    }

    private func nightRow(_ night: NightRecord) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.s) {
            HStack(spacing: DS.Space.m) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayOfWeek(night.date))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DS.Palette.textPrimary)
                    Text(dateString(night.date))
                        .font(.system(size: 11))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1fh", night.actualSleepHours))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(DS.Palette.textPrimary)
                        .monospacedDigit()
                    Text("sleep")
                        .font(.system(size: 11))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(night.allowanceEarned)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(DS.Palette.accent)
                        .monospacedDigit()
                    Text("min")
                        .font(.system(size: 11))
                        .foregroundStyle(DS.Palette.textTertiary)
                }

                VStack(alignment: .center, spacing: 2) {
                    Text(night.grade)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            night.grade.hasPrefix("A")
                                ? DS.Palette.success
                                : DS.Palette.textSecondary
                        )
                }
                .frame(width: 24, alignment: .center)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(DS.Palette.elevated)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(DS.Palette.accent)
                        .frame(width: geo.size.width * CGFloat(night.allowanceEarned) / CGFloat(maxAllowance))
                }
            }
            .frame(height: 6)
        }
    }

    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
