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
    @Published var hasWater = false
    @Published var hasSleep = false
    @Published var hasSupplements = false
    @Published var hasPhoto = false
    @Published var hasJournaled = false
    
    private var modelContext: ModelContext?
    private var currentChecklist: DailyChecklist?
    
    var todaysProgress: Double {
        let totalTasks = 7.0
        var completed = 0.0
        
        if hasRead { completed += 1 }
        if workoutsCompleted >= 2 { completed += 1 }
        if hasWater { completed += 1 }
        if hasSleep { completed += 1 }
        if hasSupplements { completed += 1 }
        if hasPhoto { completed += 1 }
        if hasJournaled { completed += 1 }
        
        return completed / totalTasks
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func loadTodaysData() {
        guard let modelContext = modelContext else { 
            print("❌ ModelContext is nil in ChecklistViewModel")
            return 
        }
        
        print("✅ Loading today's checklist data...")
        
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<DailyChecklist> { checklist in
            Calendar.current.isDate(checklist.date, inSameDayAs: today)
        }
        
        let descriptor = FetchDescriptor<DailyChecklist>(predicate: predicate)
        
        do {
            let checklists = try modelContext.fetch(descriptor)
            if let checklist = checklists.first {
                print("✅ Found existing checklist for today")
                currentChecklist = checklist
                updatePublishedValues(from: checklist)
            } else {
                print("✅ Creating new checklist for today")
                // Create new checklist for today
                let newChecklist = DailyChecklist(date: today)
                modelContext.insert(newChecklist)
                currentChecklist = newChecklist
                try modelContext.save()
            }
        } catch {
            print("❌ Error loading today's checklist: \(error)")
        }
    }
    
    private func updatePublishedValues(from checklist: DailyChecklist) {
        hasRead = checklist.hasRead
        workoutsCompleted = checklist.workoutsCompleted
        hasWater = checklist.hasWater
        hasSleep = checklist.hasSleep
        hasSupplements = checklist.hasSupplements
        hasPhoto = checklist.hasPhoto
        hasJournaled = checklist.hasJournaled
    }
    
    private func saveChanges() {
        guard let modelContext = modelContext,
              let currentChecklist = currentChecklist else { return }
        
        currentChecklist.hasRead = hasRead
        currentChecklist.workoutsCompleted = workoutsCompleted
        currentChecklist.hasWater = hasWater
        currentChecklist.hasSleep = hasSleep
        currentChecklist.hasSupplements = hasSupplements
        currentChecklist.hasPhoto = hasPhoto
        currentChecklist.hasJournaled = hasJournaled
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving checklist: \(error)")
        }
    }
    
    // Toggle functions
    func toggleRead() {
        hasRead.toggle()
        saveChanges()
    }
    
    func toggleWater() {
        hasWater.toggle()
        saveChanges()
    }
    
    func toggleSleep() {
        hasSleep.toggle()
        saveChanges()
    }
    
    func toggleSupplements() {
        hasSupplements.toggle()
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
    
    func handlePhotoSelection() {
        hasPhoto = true
        saveChanges()
    }
}