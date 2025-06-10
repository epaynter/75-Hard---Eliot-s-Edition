import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async throws {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
    
    func scheduleNotifications() {
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Check if notifications are enabled
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else { return }
        
        // Schedule water reminders if enabled
        if UserDefaults.standard.bool(forKey: "waterRemindersEnabled") {
            for hour in stride(from: 8, through: 20, by: 2) {
                scheduleWaterReminder(at: hour)
            }
        }
        
        // Schedule daily task reminder (always enabled if notifications are on)
        scheduleDailyTaskReminder()
        
        // Schedule journal prompt if enabled
        if UserDefaults.standard.bool(forKey: "journalRemindersEnabled") {
            scheduleJournalPrompt()
        }
        
        // Schedule photo reminder if enabled
        if UserDefaults.standard.bool(forKey: "photoRemindersEnabled") {
            schedulePhotoReminder()
        }
    }
    
    private func scheduleWaterReminder(at hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Hydrate! 💧"
        content.body = "Don't forget to drink your water for the 75 Hard challenge."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "water-reminder-\(hour)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleDailyTaskReminder() {
        let content = UNMutableNotificationContent()
        content.title = "75 Hard Daily Tasks"
        content.body = "Time to start your daily tasks! Check your checklist."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-tasks",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleJournalPrompt() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Journal 📝"
        content.body = "Don't forget to complete your daily journal entry."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "journal-prompt",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func schedulePhotoReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Progress Photo Time 📸"
        content.body = "Don't forget to take your daily progress photo!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "photo-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
