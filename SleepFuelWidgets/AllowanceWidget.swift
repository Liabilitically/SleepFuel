import WidgetKit
import SwiftUI

struct AllowanceEntry: TimelineEntry {
    let date: Date
    let remaining: Int
    let cap: Int
}

struct AllowanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> AllowanceEntry {
        AllowanceEntry(date: Date(), remaining: 120, cap: 180)
    }

    func getSnapshot(in context: Context, completion: @escaping (AllowanceEntry) -> Void) {
        let shared = SharedStore.read()
        completion(AllowanceEntry(date: Date(), remaining: shared.remaining, cap: shared.cap))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AllowanceEntry>) -> Void) {
        let shared = SharedStore.read()
        let entry = AllowanceEntry(date: Date(), remaining: shared.remaining, cap: shared.cap)
        // The app pushes fresh data on every change; this refresh is a backstop.
        let refresh = Date().addingTimeInterval(15 * 60)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct AllowanceWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: AllowanceEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: Double(entry.remaining), in: 0...Double(max(entry.cap, 1))) {
                Text("min")
            } currentValueLabel: {
                Text("\(entry.remaining)")
                    .monospacedDigit()
            }
            .gaugeStyle(.accessoryCircularCapacity)

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("Time left")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(entry.remaining) min")
                    .font(.headline)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        default:
            VStack(spacing: 6) {
                Text("\(entry.remaining)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("min left today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AllowanceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AllowanceWidget", provider: AllowanceProvider()) { entry in
            AllowanceWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Time left")
        .description("How many minutes you have left today.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}
