//
//  ChecklistViewModel.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import Foundation
import SwiftData

@MainActor
class ChecklistViewModel: ObservableObject {
    @Published var hasRead = false
    @Published var workoutsCompleted = 0
    @Published var waterOunces: Double = 0.0 // Changed from binary to ounces
    @Published var hasSleep = false
    @Published var supplementsTaken: [String] = []
    @Published var hasPhoto = false
    @Published var hasJournaled = false
    @Published var weight: Double?
    @Published var photoNote = ""
    
    // Challenge settings
    @Published var challengeSettings: ChallengeSettings?
    @Published var currentDay = 1
    @Published var selectedDate = Date()
    
    // Supplements
    @Published var todaySupplements: [Supplement] = []
    
    private var modelContext: ModelContext?
    private var currentChecklist: DailyChecklist?
    
    var todaysProgress: Double {
        let totalTasks = 7.0
        var completed = 0.0
        
        if hasRead { completed += 1 }
        if workoutsCompleted >= 2 { completed += 1 }
        if waterOunces >= (challengeSettings?.goalWaterOunces ?? 128.0) { completed += 1 }
        if hasSleep { completed += 1 }
        if hasAllSupplementsTaken { completed += 1 }
        if hasPhoto { completed += 1 }
        if hasJournaled { completed += 1 }
        
        return completed / totalTasks
    }
    
    var waterProgressPercentage: Double {
        let goal = challengeSettings?.goalWaterOunces ?? 128.0
        return min(waterOunces / goal, 1.0)
    }
    
    var hasAllSupplementsTaken: Bool {
        guard !todaySupplements.isEmpty else { return true }
        return todaySupplements.allSatisfy { supplement in
            supplementsTaken.contains(supplement.id.uuidString)
        }
    }
    
    var waterGoalText: String {
        let goal = challengeSettings?.goalWaterOunces ?? 128.0
        return "\(Int(waterOunces))/\(Int(goal)) oz"
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadChallengeSettings()
        SupplementManager.shared.createDefaultSupplements(context: context)
    }
    
    func loadChallengeSettings() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<ChallengeSettings>()
        do {
            let settings = try modelContext.fetch(descriptor)
            if let existing = settings.first {
                challengeSettings = existing
            } else {
                // Create default settings
                let defaultSettings = ChallengeSettings(
                    startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10)) ?? Date(),
                    duration: 75
                )
                modelContext.insert(defaultSettings)
                try modelContext.save()
                challengeSettings = defaultSettings
            }
            updateCurrentDay()
        } catch {
            print("❌ Error loading challenge settings: \(error)")
        }
    }
    
    func updateCurrentDay() {
        guard let settings = challengeSettings else { return }
        currentDay = settings.currentDay(for: selectedDate)
    }
    
    func loadDataForDate(_ date: Date) {
        selectedDate = date
        updateCurrentDay()
        loadChecklistData()
        loadTodaySupplements()
    }
    
    func loadTodaysData() {
        loadDataForDate(Date())
    }
    
    private func loadChecklistData() {
        guard let modelContext = modelContext else { 
            print("❌ ModelContext is nil in ChecklistViewModel")
            return 
        }
        
        print("✅ Loading checklist data for \(selectedDate)...")
        
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        let predicate = #Predicate<DailyChecklist> { checklist in
            checklist.date >= dayStart && checklist.date < dayEnd
        }
        
        let descriptor = FetchDescriptor<DailyChecklist>(predicate: predicate)
        
        do {
            let checklists = try modelContext.fetch(descriptor)
            if let checklist = checklists.first {
                print("✅ Found existing checklist for \(selectedDate)")
                currentChecklist = checklist
                updatePublishedValues(from: checklist)
            } else {
                print("✅ Creating new checklist for \(selectedDate)")
                let newChecklist = DailyChecklist(date: dayStart)
                modelContext.insert(newChecklist)
                currentChecklist = newChecklist
                try modelContext.save()
                resetToDefaults()
            }
        } catch {
            print("❌ Error loading checklist: \(error)")
        }
    }
    
    private func loadTodaySupplements() {
        guard let modelContext = modelContext else { return }
        todaySupplements = SupplementManager.shared.getSupplementsForTime(
            date: selectedDate,
            context: modelContext
        )
    }
    
    private func updatePublishedValues(from checklist: DailyChecklist) {
        hasRead = checklist.hasRead
        workoutsCompleted = checklist.workoutsCompleted
        waterOunces = checklist.waterOunces
        hasSleep = checklist.hasSleep
        supplementsTaken = checklist.supplementsTaken
        hasPhoto = checklist.hasPhoto
        hasJournaled = checklist.hasJournaled
        weight = checklist.weight
        photoNote = checklist.photoNote
    }
    
    private func resetToDefaults() {
        hasRead = false
        workoutsCompleted = 0
        waterOunces = 0.0
        hasSleep = false
        supplementsTaken = []
        hasPhoto = false
        hasJournaled = false
        weight = nil
        photoNote = ""
    }
    
    private func saveChanges() {
        guard let modelContext = modelContext,
              let currentChecklist = currentChecklist else { return }
        
        currentChecklist.hasRead = hasRead
        currentChecklist.workoutsCompleted = workoutsCompleted
        currentChecklist.waterOunces = waterOunces
        currentChecklist.hasSleep = hasSleep
        currentChecklist.supplementsTaken = supplementsTaken
        currentChecklist.hasPhoto = hasPhoto
        currentChecklist.hasJournaled = hasJournaled
        currentChecklist.weight = weight
        currentChecklist.photoNote = photoNote
        
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving checklist: \(error)")
        }
    }
    
    // MARK: - Toggle Functions
    func toggleRead() {
        hasRead.toggle()
        saveChanges()
    }
    
    func toggleSleep() {
        hasSleep.toggle()
        saveChanges()
    }
    
    func togglePhoto() {
        hasPhoto.toggle()
        saveChanges()
    }
    
    func toggleJournaled() {
        hasJournaled.toggle()
        saveChanges()
    }
    
    func incrementWorkouts() {
        if workoutsCompleted < 2 {
            workoutsCompleted += 1
            saveChanges()
        }
    }
    
    func decrementWorkouts() {
        if workoutsCompleted > 0 {
            workoutsCompleted -= 1
            saveChanges()
        }
    }
    
    // MARK: - Water Tracking
    func addWater(_ ounces: Double) {
        waterOunces = min(waterOunces + ounces, 200.0) // Cap at 200oz for safety
        saveChanges()
    }
    
    func removeWater(_ ounces: Double) {
        waterOunces = max(waterOunces - ounces, 0.0)
        saveChanges()
    }
    
    func setWater(_ ounces: Double) {
        waterOunces = max(0.0, min(ounces, 200.0))
        saveChanges()
    }
    
    // MARK: - Supplement Tracking
    func toggleSupplement(_ supplement: Supplement) {
        let supplementId = supplement.id.uuidString
        if supplementsTaken.contains(supplementId) {
            supplementsTaken.removeAll { $0 == supplementId }
        } else {
            supplementsTaken.append(supplementId)
        }
        saveChanges()
    }
    
    func isSupplementTaken(_ supplement: Supplement) -> Bool {
        return supplementsTaken.contains(supplement.id.uuidString)
    }
    
    // MARK: - Photo & Weight
    func handlePhotoSelection() {
        hasPhoto = true
        saveChanges()
    }
    
    func updateWeight(_ newWeight: Double?) {
        weight = newWeight
        saveChanges()
    }
    
    func updatePhotoNote(_ note: String) {
        photoNote = note
        saveChanges()
    }
    
    // MARK: - Day Navigation
    func canNavigateToPreviousDay() -> Bool {
        guard let settings = challengeSettings else { return false }
        return selectedDate > settings.startDate
    }
    
    func canNavigateToNextDay() -> Bool {
        guard let settings = challengeSettings else { return false }
        return selectedDate < min(Date(), settings.endDate)
    }
    
    func navigateToPreviousDay() {
        guard canNavigateToPreviousDay() else { return }
        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        loadDataForDate(previousDay)
    }
    
    func navigateToNextDay() {
        guard canNavigateToNextDay() else { return }
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        loadDataForDate(nextDay)
    }
    
    func navigateToToday() {
        loadDataForDate(Date())
    }
    
    // MARK: - Challenge Progress
    var overallProgress: Double {
        guard let settings = challengeSettings else { return 0.0 }
        return settings.progressPercentage
    }
    
    var daysCompleted: Int {
        guard let settings = challengeSettings else { return 0 }
        return max(0, settings.currentDay() - 1)
    }
    
    var totalDays: Int {
        return challengeSettings?.duration ?? 75
    }
}