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
    
    // Challenge settings - cache these to avoid repeated fetches
    @Published var challengeSettings: ChallengeSettings?
    @Published var currentDay = 1
    @Published var selectedDate = Date()
    
    // Supplements - lazy load and cache
    @Published var todaySupplements: [Supplement] = []
    
    // NEW: Custom habits support
    @Published var customHabits: [CustomHabit] = []
    @Published var customHabitEntries: [UUID: CustomHabitEntry] = [:]
    
    private var modelContext: ModelContext?
    private var currentChecklist: DailyChecklist?
    
    // PERFORMANCE: Cache frequently used calculations
    private var cachedTodaysProgress: Double?
    private var lastProgressCalculationDate: Date?
    
    // PERFORMANCE: Debounce save operations to avoid excessive writes
    private var saveTimer: Timer?
    
    var todaysProgress: Double {
        // Cache today's progress calculation to avoid repeated computation
        let today = Calendar.current.startOfDay(for: selectedDate)
        if let cached = cachedTodaysProgress,
           let lastCalc = lastProgressCalculationDate,
           Calendar.current.isDate(lastCalc, inSameDayAs: today) {
            return cached
        }
        
        let totalTasks = 7.0
        var completed = 0.0
        
        if hasRead { completed += 1 }
        // NEW: Each workout contributes 50% instead of requiring 2 full workouts
        completed += min(Double(workoutsCompleted) * 0.5, 1.0)
        if waterOunces >= (challengeSettings?.goalWaterOunces ?? 128.0) { completed += 1 }
        if hasSleep { completed += 1 }
        if hasAllSupplementsTaken { completed += 1 }
        if hasPhoto { completed += 1 }
        if hasJournaled { completed += 1 }
        
        let progress = completed / totalTasks
        
        // Cache the result
        cachedTodaysProgress = progress
        lastProgressCalculationDate = today
        
        return progress
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
    
    // NEW: Water goal with conversions
    var waterGoalWithConversions: String {
        let goal = challengeSettings?.goalWaterOunces ?? 128.0
        let cups = goal / 8.0
        let gallons = goal / 128.0
        return "\(Int(goal))oz = \(String(format: "%.1f", gallons)) gal = \(Int(cups)) cups"
    }
    
    // NEW: Check if photo checkbox should be locked
    var isPhotoLocked: Bool {
        return currentChecklist?.isPhotoLocked ?? false
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadChallengeSettings()
        loadCustomHabits()
        // Only create default supplements if none exist
        if todaySupplements.isEmpty {
            // Don't create default supplements - user needs to add them manually
        }
    }
    
    func loadChallengeSettings() {
        guard let modelContext = modelContext else { return }
        
        // PERFORMANCE: Only load if not already cached
        if challengeSettings != nil { return }
        
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
    
    // PERFORMANCE: Load custom habits with efficient query
    func loadCustomHabits() {
        guard let modelContext = modelContext else { return }
        
        // Only reload if we don't have data or it's stale
        if !customHabits.isEmpty { return }
        
        let descriptor = FetchDescriptor<CustomHabit>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            customHabits = try modelContext.fetch(descriptor)
            if !customHabits.isEmpty {
                loadCustomHabitEntries()
            }
        } catch {
            print("❌ Error loading custom habits: \(error)")
        }
    }
    
    // PERFORMANCE: Efficient custom habit entries loading
    func loadCustomHabitEntries() {
        guard let modelContext = modelContext, !customHabits.isEmpty else { return }
        
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        let predicate = #Predicate<CustomHabitEntry> { entry in
            entry.date >= dayStart && entry.date < dayEnd
        }
        let descriptor = FetchDescriptor<CustomHabitEntry>(predicate: predicate)
        
        do {
            let entries = try modelContext.fetch(descriptor)
            customHabitEntries = Dictionary(uniqueKeysWithValues: entries.map { ($0.habitId, $0) })
        } catch {
            print("❌ Error loading custom habit entries: \(error)")
        }
    }
    
    func updateCurrentDay() {
        guard let settings = challengeSettings else { return }
        currentDay = settings.currentDay(for: selectedDate)
    }
    
    func loadDataForDate(_ date: Date) {
        // PERFORMANCE: Avoid unnecessary work if date hasn't changed
        if Calendar.current.isDate(selectedDate, inSameDayAs: date) && currentChecklist != nil {
            return
        }
        
        selectedDate = date
        updateCurrentDay()
        loadChecklistData()
        loadTodaySupplements()
        loadCustomHabitEntries()
    }
    
    func loadTodaysData() {
        loadDataForDate(Date())
    }
    
    private func loadChecklistData() {
        guard let modelContext = modelContext else { 
            print("❌ ModelContext is nil in ChecklistViewModel")
            return 
        }
        
        // PERFORMANCE: Optimize query for single day
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        let predicate = #Predicate<DailyChecklist> { checklist in
            checklist.date >= dayStart && checklist.date < dayEnd
        }
        
        // PERFORMANCE: Limit to 1 result since we only expect one per day
        let descriptor = FetchDescriptor<DailyChecklist>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let checklists = try modelContext.fetch(descriptor)
            if let checklist = checklists.first {
                currentChecklist = checklist
                updatePublishedValues(from: checklist)
            } else {
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
        
        // PERFORMANCE: Use more efficient query with limit if we have many supplements
        let descriptor = FetchDescriptor<Supplement>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            let allSupplements = try modelContext.fetch(descriptor)
            // PERFORMANCE: Filter in memory instead of complex database query
            todaySupplements = allSupplements.filter { supplement in
                // Always show all supplements - filtering by time of day is just for UI hints
                return true
            }
        } catch {
            print("❌ Error loading supplements: \(error)")
        }
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
        // PERFORMANCE: Debounce save operations to avoid excessive database writes
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.performSave()
        }
    }
    
    // PERFORMANCE: Immediate save for critical operations
    private func saveImmediately() {
        saveTimer?.invalidate()
        performSave()
    }
    
    // FIXED: Add @MainActor annotation to fix main actor isolation error
    @MainActor
    private func performSave() {
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
        
        // Invalidate progress cache when data changes
        cachedTodaysProgress = nil
        
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
    
    // NEW: Photo toggle with locking logic
    func togglePhoto() {
        // Only allow toggle if photo is not locked
        if !isPhotoLocked {
            hasPhoto.toggle()
            saveChanges()
        }
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
    
    // NEW: Refresh supplements function to be called when supplements are added/modified
    func refreshSupplements() {
        loadTodaySupplements()
        // Force UI update
        objectWillChange.send()
    }
    
    // NEW: Update supplements for current and future days when supplements are added
    func updateSupplementsForCurrentAndFutureDays() {
        guard let modelContext = modelContext,
              let settings = challengeSettings else { return }
        
        let today = Date()
        let endDate = settings.endDate
        
        // Get all dates from today to end of challenge
        var currentDate = max(today, settings.startDate)
        var datesToUpdate: [Date] = []
        
        while currentDate <= endDate {
            datesToUpdate.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Update checklists for these dates to include new supplements
        for date in datesToUpdate {
            let dayStart = Calendar.current.startOfDay(for: date)
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
            
            let predicate = #Predicate<DailyChecklist> { checklist in
                checklist.date >= dayStart && checklist.date < dayEnd
            }
            
            let descriptor = FetchDescriptor<DailyChecklist>(predicate: predicate)
            
            do {
                let checklists = try modelContext.fetch(descriptor)
                // FIXED: Replace unused variable with boolean test
                if !checklists.isEmpty {
                    // Existing checklists don't need to be updated - supplements are loaded dynamically
                    // Just ensure the current view reflects the new supplements if today
                    if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
                        refreshSupplements()
                    }
                }
            } catch {
                print("❌ Error updating checklist for supplements: \(error)")
            }
        }
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
    
    // NEW: Store photo thumbnail data
    func updatePhotoThumbnail(_ data: Data?) {
        currentChecklist?.photoThumbnailData = data
        saveChanges()
    }
    
    // MARK: - Day Navigation (FIXED - Remove 2-day limitation)
    func canNavigateToPreviousDay() -> Bool {
        guard let settings = challengeSettings else { return false }
        return selectedDate > settings.startDate
    }
    
    func canNavigateToNextDay() -> Bool {
        guard let settings = challengeSettings else { return false }
        // NEW: Allow navigation through entire challenge window, not just 2 days
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
    
    // NEW: Jump to specific day
    func navigateToDay(_ day: Int) {
        guard let settings = challengeSettings,
              day >= 1 && day <= settings.duration else { return }
        
        if let targetDate = Calendar.current.date(byAdding: .day, value: day - 1, to: settings.startDate) {
            loadDataForDate(targetDate)
        }
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
    
    // NEW: Custom habit functions
    func toggleCustomHabit(_ habit: CustomHabit) {
        guard let modelContext = modelContext else { return }
        
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        
        if let entry = customHabitEntries[habit.id] {
            entry.isCompleted.toggle()
        } else {
            let newEntry = CustomHabitEntry(date: dayStart, habitId: habit.id)
            newEntry.isCompleted = true
            modelContext.insert(newEntry)
            customHabitEntries[habit.id] = newEntry
        }
        
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving custom habit entry: \(error)")
        }
    }
    
    func updateCustomHabitCount(_ habit: CustomHabit, count: Int) {
        guard let modelContext = modelContext else { return }
        
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        
        if let entry = customHabitEntries[habit.id] {
            entry.count = count
            entry.isCompleted = count >= habit.targetCount
        } else {
            let newEntry = CustomHabitEntry(date: dayStart, habitId: habit.id)
            newEntry.count = count
            newEntry.isCompleted = count >= habit.targetCount
            modelContext.insert(newEntry)
            customHabitEntries[habit.id] = newEntry
        }
        
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving custom habit count: \(error)")
        }
    }
    
    func isCustomHabitCompleted(_ habit: CustomHabit) -> Bool {
        return customHabitEntries[habit.id]?.isCompleted ?? false
    }
    
    func getCustomHabitCount(_ habit: CustomHabit) -> Int {
        return customHabitEntries[habit.id]?.count ?? 0
    }
}