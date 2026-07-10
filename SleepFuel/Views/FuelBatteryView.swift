import SwiftUI

/// The centerpiece of the dashboard: a segmented battery showing remaining
/// fuel, with the minute count as the dominant element on screen.
struct FuelBatteryView: View {
    let fuelMinutes: Int
    let capMinutes: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let cellCount = 10

    private var progress: Double {
        guard capMinutes > 0 else { return 0 }
        return min(1, Double(fuelMinutes) / Double(capMinutes))
    }

    private var filledCells: Int {
        guard fuelMinutes > 0 else { return 0 }
        return max(1, Int((progress * Double(cellCount)).rounded()))
    }

    var body: some View {
        VStack(spacing: DS.Space.m) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(fuelMinutes)")
                    .font(DS.Fonts.display)
                    .foregroundStyle(DS.Palette.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(DS.motion(reduceMotion), value: fuelMinutes)

                Text("min")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(DS.Palette.textSecondary)
            }

            HStack(spacing: 3) {
                // Battery body
                HStack(spacing: 4) {
                    ForEach(0..<cellCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(index < filledCells ? DS.Palette.accent : DS.Palette.elevated)
                            .animation(DS.motion(reduceMotion), value: filledCells)
                    }
                }
                .padding(5)
                .frame(height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                        .strokeBorder(DS.Palette.border, lineWidth: 1)
                )

                // Battery terminal
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(DS.Palette.border)
                    .frame(width: 4, height: 20)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(fuelMinutes) minutes of fuel available, out of a \(capMinutes) minute cap")
    }
}
