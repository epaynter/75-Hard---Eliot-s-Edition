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
    var photoThumbnailData: Data? // Store thumbnail for quick display
    
    init(date: Date) {
        self.date = date
    }
    
    var completionPercentage: Double {
        let totalTasks = 7.0
        var completed = 0.0
        
        if hasRead { completed += 1 }
        completed += min(Double(workoutsCompleted) * 0.5, 1.0)
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
    
    var isPhotoLocked: Bool {
        return hasPhoto && (photoPath != nil || photoThumbnailData != nil)
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
    
    var shouldShowForCurrentTime: Bool {
        let now = Calendar.current.component(.hour, from: Date())
        
        switch timeOfDay {
        case .morning:
            return now >= 6 && now < 12
        case .evening:
            return now >= 18 || now < 6
        case .both:
            return true
        }
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
    var userAffirmation: String = ""
    var hasFutureStart: Bool {
        return startDate > Date()
    }
    
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
    
    var daysUntilStart: Int {
        guard hasFutureStart else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? 0
    }
    
    var waterGoalInCups: Double {
        return goalWaterOunces / 8.0 // 8oz per cup
    }
    
    var waterGoalInGallons: Double {
        return goalWaterOunces / 128.0 // 128oz per gallon
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

@Model
final class CustomHabit {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var color: String // Store as hex string
    var isActive: Bool = true
    var requiresCount: Bool = false // If true, shows number input instead of checkbox
    var targetCount: Int = 1
    var createdDate: Date = Date()
    
    init(name: String, icon: String = "checkmark.circle", color: String = "#007AFF", requiresCount: Bool = false, targetCount: Int = 1) {
        self.name = name
        self.icon = icon
        self.color = color
        self.requiresCount = requiresCount
        self.targetCount = targetCount
    }
}

@Model
final class CustomHabitEntry {
    var date: Date
    var habitId: UUID
    var isCompleted: Bool = false
    var count: Int = 0
    
    init(date: Date, habitId: UUID) {
        self.date = date
        self.habitId = habitId
    }
}
