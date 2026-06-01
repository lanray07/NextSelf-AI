import Foundation
import UserNotifications

struct NotificationService {
    func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleDailyMissionReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Your future self is waiting"
        content.body = "Complete one NextSelf mission today."
        content.sound = .default

        var date = DateComponents()
        date.hour = 8
        date.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-nextself-mission", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
