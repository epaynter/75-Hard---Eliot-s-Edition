//
//  Models.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import Foundation
import SwiftData

@Model
final class DailyChecklist {
    var date: Date
    var hasRead: Bool = false
    var workoutsCompleted: Int = 0
    var waterOunces: Double = 0.0 // Changed from binary to ounces
    var hasSleep: Bool = false
    var supplementsTaken: [String] = [] // Track which supplements were taken
    var hasPhoto: Bool = false
    var hasJournaled: Bool = false
    var photoPath: String?
    var weight: Double? // Optional weight entry for the day
    var photoNote: String = "" // Optional note with photo
    
    init(date: Date) {
        self.date = date
    }
    
    var completionPercentage: Double {
        let totalTasks = 7.0
        var completed = 0.0
        
        if hasRead { completed += 1 }
        if workoutsCompleted >= 2 { completed += 1 }
        if waterOunces >= 128.0 { completed += 1 } // 1 gallon = 128oz
        if hasSleep { completed += 1 }
        if hasAllSupplementsTaken { completed += 1 }
        if hasPhoto { completed += 1 }
        if hasJournaled { completed += 1 }
        
        return completed / totalTasks
    }
    
    var waterProgressPercentage: Double {
        return min(waterOunces / 128.0, 1.0) // Progress toward 1 gallon
    }
    
    var hasAllSupplementsTaken: Bool {
        // For now, return true if any supplements are taken
        // This will be properly calculated in the ViewModel with ModelContext
        return !supplementsTaken.isEmpty
    }
}

@Model
final class JournalEntry {
    var date: Date
    var morningText: String = ""
    var eveningText: String = ""
    var morningPrompt: String = ""
    var eveningPrompt: String = ""
    
    init(date: Date, morningPrompt: String = "", eveningPrompt: String = "") {
        self.date = date
        self.morningPrompt = morningPrompt
        self.eveningPrompt = eveningPrompt
    }
}

@Model
final class Supplement {
    var id: UUID = UUID()
    var name: String
    var dosage: String
    var timeOfDay: SupplementTime
    var isActive: Bool = true
    var createdDate: Date = Date()
    
    init(name: String, dosage: String, timeOfDay: SupplementTime) {
        self.name = name
        self.dosage = dosage
        self.timeOfDay = timeOfDay
    }
}

enum SupplementTime: String, CaseIterable, Codable {
    case morning = "AM"
    case evening = "PM"
    case both = "Both"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .evening: return "Evening"
        case .both: return "Morning & Evening"
        }
    }
}

@Model
final class ChallengeSettings {
    var startDate: Date
    var duration: Int = 75 // Default 75 days
    var goalWaterOunces: Double = 128.0 // 1 gallon default
    var createdDate: Date = Date()
    
    init(startDate: Date, duration: Int = 75) {
        self.startDate = startDate
        self.duration = duration
    }
    
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: duration - 1, to: startDate) ?? startDate
    }
    
    func currentDay(for date: Date = Date()) -> Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 0
        return max(1, min(days + 1, duration))
    }
    
    var isActive: Bool {
        let today = Date()
        return today >= startDate && today <= endDate
    }
    
    var progressPercentage: Double {
        let currentDay = currentDay()
        return Double(currentDay) / Double(duration)
    }
}

@Model
final class NotificationPreference {
    var id: UUID = UUID()
    var type: NotificationType
    var isEnabled: Bool = true
    var scheduledTime: Date // Time of day for notification
    var customMessage: String = ""
    
    init(type: NotificationType, scheduledTime: Date) {
        self.type = type
        self.scheduledTime = scheduledTime
    }
}

enum NotificationType: String, CaseIterable, Codable {
    case morningJournal = "morning_journal"
    case waterReminder = "water_reminder"
    case workoutReminder = "workout_reminder"
    case supplementReminder = "supplement_reminder"
    case eveningReflection = "evening_reflection"
    case photoReminder = "photo_reminder"
    case bedtimeReminder = "bedtime_reminder"
    
    var defaultMessage: String {
        switch self {
        case .morningJournal: return "Start your day with morning reflection 🌅"
        case .waterReminder: return "Time for some water! Stay hydrated 💧"
        case .workoutReminder: return "Ready to crush your workout? 💪"
        case .supplementReminder: return "Time for your supplements 💊"
        case .eveningReflection: return "Time for evening reflection 🌙"
        case .photoReminder: return "Don't forget your progress photo! 📸"
        case .bedtimeReminder: return "Time to wind down for quality sleep 😴"
        }
    }
    
    var displayName: String {
        switch self {
        case .morningJournal: return "Morning Journal"
        case .waterReminder: return "Water Reminder"
        case .workoutReminder: return "Workout Reminder"
        case .supplementReminder: return "Supplement Reminder"
        case .eveningReflection: return "Evening Reflection"
        case .photoReminder: return "Photo Reminder"
        case .bedtimeReminder: return "Bedtime Reminder"
        }
    }
}
