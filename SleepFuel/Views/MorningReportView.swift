import SwiftUI

struct MorningReportView: View {
    let report: NightRecord
    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Space.m) {
                // Grade header
                VStack(spacing: DS.Space.s) {
                    Text("Morning report")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.6)
                        .textCase(.uppercase)
                        .foregroundStyle(DS.Palette.textTertiary)

                    Text(report.grade)
                        .font(DS.Fonts.display)
                        .foregroundStyle(gradeColor)
                        .scaleEffect(revealed || reduceMotion ? 1 : 0.8)
                        .opacity(revealed || reduceMotion ? 1 : 0)

                    Text(gradeLine)
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textSecondary)
                }
                .padding(.top, DS.Space.xl)
                .padding(.bottom, DS.Space.s)

                // Headline numbers
                HStack(spacing: DS.Space.s) {
                    StatTile(
                        value: TimeFormat.hoursMinutes(report.protectedMinutes),
                        label: "Protected sleep"
                    )
                    StatTile(
                        value: "\(report.fuelEarned) min",
                        label: "Fuel earned"
                    )
                }

                // Breakdown
                VStack(alignment: .leading, spacing: DS.Space.m) {
                    SectionHeader(title: "Breakdown")
                    PenaltyBreakdownView(record: report)
                    StatusRow(
                        label: "Anchor",
                        value: report.anchorCompleted ? "Complete" : "Missed",
                        valueColor: report.anchorCompleted ? DS.Palette.success : DS.Palette.accent
                    )
                }
                .padding(DS.Space.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .dsCard()

                // Takeaway
                VStack(alignment: .leading, spacing: DS.Space.s) {
                    SectionHeader(title: "Takeaway")
                    Text(FuelEngine.takeaway(for: report))
                        .font(.system(size: 15))
                        .foregroundStyle(DS.Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .padding(DS.Space.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .dsCard(elevated: true)

                // Actions
                VStack(spacing: DS.Space.s) {
                    PrimaryButton(title: "Use fuel today") {
                        state.presentedReport = nil
                    }
                    SecondaryButton(title: "Adjust tonight") {
                        state.presentedReport = nil
                        state.path = [.editSchedule]
                    }
                }
                .padding(.top, DS.Space.s)
            }
            .padding(DS.Space.l)
        }
        .background(DS.Palette.obsidian.ignoresSafeArea())
        .onAppear {
            withAnimation(DS.motion(reduceMotion)) {
                revealed = true
            }
        }
    }

    private var gradeColor: Color {
        if report.grade.hasPrefix("A") { return DS.Palette.success }
        if report.grade.hasPrefix("F") || report.grade.hasPrefix("D") { return DS.Palette.accent }
        return DS.Palette.textPrimary
    }

    private var gradeLine: String {
        if report.grade.hasPrefix("A") {
            return "You protected \(percentProtected)% of your window."
        }
        if report.grade.hasPrefix("F") {
            return "The night broke early. Tomorrow runs on \(report.fuelEarned) minutes."
        }
        return "\(percentProtected)% of your window converted to fuel."
    }

    private var percentProtected: Int {
        guard report.scheduledMinutes > 0 else { return 0 }
        return Int((Double(report.protectedMinutes) / Double(report.scheduledMinutes) * 100).rounded())
    }
}
