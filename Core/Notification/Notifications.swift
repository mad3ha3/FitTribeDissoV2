import Foundation
import UserNotifications //for local notifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    //requests permission from user to have notifications
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
            if allowed {
                print("Notifications Allowed!")
                self.dispatchDailyNotification() //schedules if allowed
            } else {
                print("Permission denied")
            }
        }
    }
    
    //daily natifs scheduled
    func dispatchDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Planning on going gym?"
        content.subtitle = "Remember to log your attendance!!"
        content.sound = UNNotificationSound.default
        
        //trigger times are set
        var dateComponent = DateComponents()
        dateComponent.hour = 10
        dateComponent.minute = 00
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        let request = UNNotificationRequest(identifier: "DailyNotification", content: content, trigger: trigger)
        
        //add request
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
