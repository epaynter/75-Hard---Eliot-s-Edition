import Foundation
import SwiftData

@Model
final class JournalEntry {
    @Attribute(.unique) var date: Date
    var morningText: String = ""
    var eveningText: String = ""
    var morningPrompt: String = ""
    var eveningPrompt: String = ""
    var freeWriteText: String = ""
    
    // Relationship
    @Relationship(inverse: \DailyChecklist.journalEntry) var checklist: DailyChecklist?
    
    // Computed properties
    var hasEntries: Bool {
        !morningText.isEmpty || !eveningText.isEmpty || !freeWriteText.isEmpty
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    init(
        date: Date,
        morningPrompt: String = "",
        eveningPrompt: String = "",
        checklist: DailyChecklist? = nil
    ) {
        self.date = date
        self.morningPrompt = morningPrompt
        self.eveningPrompt = eveningPrompt
        self.checklist = checklist
    }
}
