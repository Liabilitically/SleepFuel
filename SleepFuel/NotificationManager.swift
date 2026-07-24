import Foundation
import UserNotifications

/// Real local notifications around the sleep window.
enum NotificationManager {
    private static let bedtimeID = "sleepfuel.bedtime.reminder"
    private static let morningID = "sleepfuel.morning.report"

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// (Re)schedules the two daily notifications. Call whenever the
    /// sleep schedule changes.
    static func reschedule(bedtime: Date, wakeTime: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [bedtimeID, morningID])

        let cal = Calendar.current

        // 5 minutes before bed
        if let reminderDate = cal.date(byAdding: .minute, value: -5, to: bedtime) {
            let comps = cal.dateComponents([.hour, .minute], from: reminderDate)
            let content = UNMutableNotificationContent()
            content.title = "Bed time in 5 minutes"
            content.body = "Put your phone down to keep tomorrow's time."
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            center.add(UNNotificationRequest(identifier: bedtimeID, content: content, trigger: trigger))
        }

        // At wake time
        let comps = cal.dateComponents([.hour, .minute], from: wakeTime)
        let content = UNMutableNotificationContent()
        content.title = "Good morning"
        content.body = "Your time for today is ready. Open SleepFuel to see it."
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: morningID, content: content, trigger: trigger))
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
