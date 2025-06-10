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
    var hasWater: Bool = false
    var hasSleep: Bool = false
    var hasSupplements: Bool = false
    var hasPhoto: Bool = false
    var hasJournaled: Bool = false
    var photoPath: String?
    
    init(date: Date) {
        self.date = date
    }
    
    var completionPercentage: Double {
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
