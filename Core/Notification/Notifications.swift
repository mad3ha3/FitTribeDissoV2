

import Foundation
import UserNotifications

class Notification {
    
    static let shared = Notification()
    
    private init() {}
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
            if allowed {
                print("Notifications Allowed!")
            } else {
                print("Permission denied")
            }
        }
    }
    
    func dispatchDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Planning on going gym?"
        content.subtitle = "Remember to log your attendance!!"
        content.sound = UNNotificationSound.default
        
        var dateComponent = DateComponents()
        dateComponent.hour = 10
        dateComponent.minute = 00
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        let request = UNNotificationRequest(identifier: "DailyNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("failed to schedule notification: \(error)")
            } else {
                print("notification scheduled")
            }
        }
        
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["DailyNotification"])
    }
    
}
