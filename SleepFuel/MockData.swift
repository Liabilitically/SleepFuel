import Foundation

enum MockData {

    // MARK: - Blockable apps & categories

    static let apps: [BlockTarget] = [
        BlockTarget(id: "tiktok", name: "TikTok", symbol: "music.note", isCategory: false),
        BlockTarget(id: "instagram", name: "Instagram", symbol: "camera.fill", isCategory: false),
        BlockTarget(id: "youtube", name: "YouTube", symbol: "play.rectangle.fill", isCategory: false),
        BlockTarget(id: "reddit", name: "Reddit", symbol: "bubble.left.fill", isCategory: false),
        BlockTarget(id: "x", name: "X", symbol: "at", isCategory: false),
        BlockTarget(id: "snapchat", name: "Snapchat", symbol: "bolt.fill", isCategory: false),
        BlockTarget(id: "netflix", name: "Netflix", symbol: "play.tv.fill", isCategory: false),
        BlockTarget(id: "safari", name: "Safari", symbol: "safari.fill", isCategory: false)
    ]

    static let categories: [BlockTarget] = [
        BlockTarget(id: "cat.games", name: "Games", symbol: "gamecontroller.fill", isCategory: true),
        BlockTarget(id: "cat.entertainment", name: "Entertainment", symbol: "tv.fill", isCategory: true),
        BlockTarget(id: "cat.social", name: "Social", symbol: "person.2.fill", isCategory: true),
        BlockTarget(id: "cat.shopping", name: "Shopping", symbol: "bag.fill", isCategory: true)
    ]

    static let allTargets: [BlockTarget] = apps + categories

    static let defaultSelection: Set<String> = ["tiktok", "instagram", "youtube"]

    // MARK: - Seeded history (last 7 nights, most recent first)

    static func seededHistory(referenceDate: Date = Date()) -> [NightRecord] {
        let cal = Calendar.current

        func night(daysAgo: Int, penalties: [Penalty], anchor: Bool) -> NightRecord {
            let date = cal.date(byAdding: .day, value: -daysAgo, to: referenceDate) ?? referenceDate
            return FuelEngine.makeReport(
                date: date,
                scheduled: 480,
                penalties: penalties,
                anchorCompleted: anchor,
                mode: .normal,
                cap: 180
            )
        }

        return [
            night(daysAgo: 1,
                  penalties: [Penalty(kind: .lateStart, minutes: 18),
                              Penalty(kind: .emergencyUnlock, minutes: 12)],
                  anchor: true),
            night(daysAgo: 2, penalties: [], anchor: true),
            night(daysAgo: 3,
                  penalties: [Penalty(kind: .lateStart, minutes: 9)],
                  anchor: true),
            night(daysAgo: 4,
                  penalties: [Penalty(kind: .missedAnchor, minutes: 30),
                              Penalty(kind: .emergencyUnlock, minutes: 10)],
                  anchor: false),
            night(daysAgo: 5,
                  penalties: [Penalty(kind: .lateStart, minutes: 26)],
                  anchor: true),
            night(daysAgo: 6,
                  penalties: [Penalty(kind: .manualSkip, minutes: 95),
                              Penalty(kind: .lateStart, minutes: 12)],
                  anchor: true),
            night(daysAgo: 7,
                  penalties: [Penalty(kind: .lateStart, minutes: 4)],
                  anchor: true)
        ]
    }
}
