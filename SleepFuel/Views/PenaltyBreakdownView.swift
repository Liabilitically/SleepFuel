import SwiftUI

struct PenaltyBreakdownView: View {
    let record: NightRecord

    var body: some View {
        VStack(spacing: DS.Space.s) {
            StatusRow(
                label: "Scheduled window",
                value: "+\(record.scheduledMinutes) min"
            )

            if record.penalties.isEmpty {
                StatusRow(
                    label: "Penalties",
                    value: "None",
                    valueColor: DS.Palette.success
                )
            } else {
                ForEach(record.penalties) { penalty in
                    StatusRow(
                        label: penalty.kind.label,
                        value: "−\(penalty.minutes) min",
                        valueColor: DS.Palette.accent
                    )
                }
            }

            Rectangle()
                .fill(DS.Palette.border)
                .frame(height: DS.hairline)
                .padding(.vertical, 4)

            StatusRow(
                label: "Protected sleep",
                value: TimeFormat.hoursMinutes(record.protectedMinutes)
            )

            StatusRow(
                label: "Fuel earned",
                value: "\(record.fuelEarned) min",
                valueColor: DS.Palette.accent
            )
        }
    }
}
