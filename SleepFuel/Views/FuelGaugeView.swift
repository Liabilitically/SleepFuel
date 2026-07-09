import SwiftUI

struct FuelGaugeView: View {
    let fuelMinutes: Int
    let capMinutes: Int
    var caption: String = "min fuel available"

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var progress: CGFloat {
        guard capMinutes > 0 else { return 0 }
        return min(1, CGFloat(fuelMinutes) / CGFloat(capMinutes))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(DS.Palette.elevated, style: StrokeStyle(lineWidth: 10, lineCap: .round))

            Circle()
                .trim(from: 0, to: progress)
                .stroke(DS.Palette.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(DS.motion(reduceMotion), value: progress)

            VStack(spacing: 4) {
                Text("\(fuelMinutes)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.Palette.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(DS.motion(reduceMotion), value: fuelMinutes)

                Text(caption)
                    .font(.system(size: 13))
                    .foregroundStyle(DS.Palette.textTertiary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(fuelMinutes) minutes of fuel available, out of a \(capMinutes) minute cap")
    }
}
