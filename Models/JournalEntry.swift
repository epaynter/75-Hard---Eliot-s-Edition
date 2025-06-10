import Foundation
import SwiftData

@Model
class JournalEntry {
    @Attribute(.unique) var date: Date
    var morningEntry: String
    var eveningEntry: String
    var weeklyPrompt: String
    var weeklyResponse: String
    
    // Relationship
    @Relationship(inverse: \DailyChecklist.journalEntry) var checklist: DailyChecklist?
    
    // Computed properties
    var hasEntries: Bool {
        !morningEntry.isEmpty || !eveningEntry.isEmpty || !weeklyResponse.isEmpty
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    init(
        date: Date,
        morningEntry: String = "",
        eveningEntry: String = "",
        weeklyPrompt: String = "",
        weeklyResponse: String = "",
        checklist: DailyChecklist? = nil
    ) {
        self.date = date
        self.morningEntry = morningEntry
        self.eveningEntry = eveningEntry
        self.weeklyPrompt = weeklyPrompt
        self.weeklyResponse = weeklyResponse
        self.checklist = checklist
    }
}
