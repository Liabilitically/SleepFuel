import WidgetKit
import SwiftUI

struct SleepNightLiveActivity: Widget {
    private let accent = Color(red: 1.0, green: 0.34, blue: 0.13)

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SleepActivityAttributes.self) { context in
            // Lock screen banner
            HStack(spacing: 12) {
                Image(systemName: "moon.fill")
                    .font(.title2)
                    .foregroundStyle(accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tomorrow's time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(context.state.remainingMinutes) min")
                        .font(.title2.bold())
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(context.attributes.bedtimeText) – \(context.attributes.wakeTimeText)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Text(context.state.isDraining ? "Phone open — draining" : "Sleeping")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(context.state.isDraining ? .red : .green)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.55))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(accent)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.remainingMinutes) min tomorrow")
                        .font(.headline)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.isDraining ? "Phone open — time is draining" : "Locked in. Good night.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "moon.fill")
                    .foregroundStyle(accent)
            } compactTrailing: {
                Text("\(context.state.remainingMinutes)m")
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "moon.fill")
                    .foregroundStyle(accent)
            }
        }
    }
}
