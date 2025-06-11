//
//  NotificationManager.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled = false
    
    private init() {
        checkNotificationPermission()
    }
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                notificationsEnabled = granted
            }
            
            if granted {
                await scheduleAllNotifications()
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleAllNotifications() async {
        await cancelAllNotifications()
        
        guard notificationsEnabled else { return }
        
        // Morning journal reminder (8:00 AM)
        await scheduleMorningJournal()
        
        // Water reminders (every 2 hours from 10 AM to 8 PM)
        await scheduleWaterReminders()
        
        // Evening reflection and photo reminder (8:00 PM)
        await scheduleEveningReminder()
        
        // Bedtime reminder (10:00 PM)
        await scheduleBedtimeReminder()
    }
    
    private func scheduleMorningJournal() async {
        let content = UNMutableNotificationContent()
        content.title = "Good Morning! 🌅"
        content.body = "Start your day with morning reflection and set your intentions."
        content.sound = .default
        content.categoryIdentifier = "MORNING_JOURNAL"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "morning_journal", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling morning journal notification: \(error)")
        }
    }
    
    private func scheduleWaterReminders() async {
        let times = [10, 12, 14, 16, 18, 20] // 10 AM to 8 PM, every 2 hours
        
        for (index, hour) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Hydration Check 💧"
            content.body = "Time for some water! Stay hydrated throughout your 75 Hard journey."
            content.sound = .default
            content.categoryIdentifier = "WATER_REMINDER"
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "water_reminder_\(index)", content: content, trigger: trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error scheduling water reminder: \(error)")
            }
        }
    }
    
    private func scheduleEveningReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Evening Check-in 🌙"
        content.body = "Time for your evening reflection and progress photo. How did today go?"
        content.sound = .default
        content.categoryIdentifier = "EVENING_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "evening_reminder", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling evening reminder: \(error)")
        }
    }
    
    private func scheduleBedtimeReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Bedtime Reminder 😴"
        content.body = "Time to wind down. Remember to get 7+ hours of sleep for your 75 Hard challenge!"
        content.sound = .default
        content.categoryIdentifier = "BEDTIME_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 22
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "bedtime_reminder", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling bedtime reminder: \(error)")
        }
    }
    
    func scheduleWorkoutReminder(for date: Date, title: String) async {
        let content = UNMutableNotificationContent()
        content.title = "Workout Time 💪"
        content.body = title
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "workout_\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling workout reminder: \(error)")
        }
    }
    
    private func cancelAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func disableNotifications() async {
        await cancelAllNotifications()
        notificationsEnabled = false
    }
    
    func enableNotifications() async {
        await requestPermission()
    }
    
    // NEW: Add method that matches the expected interface
    func requestNotificationPermission() {
        Task {
            await requestPermission()
        }
    }
}