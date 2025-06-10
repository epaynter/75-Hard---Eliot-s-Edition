import Foundation
import SwiftData

@Model
class DailyChecklist {
    @Attribute(.unique) var date: Date
    var read: Bool
    var workoutsCompleted: Int
    var waterDrank: Bool
    var sleepMet: Bool
    var supplementsTaken: Bool
    var photoTaken: Bool
    var journaled: Bool
    
    // Relationships
    @Relationship(deleteRule: .cascade) var journalEntry: JournalEntry?
    @Relationship(deleteRule: .cascade) var workoutDay: WorkoutDay?
    
    // Computed properties
    var isComplete: Bool {
        read &&
        workoutsCompleted >= 2 &&
        waterDrank &&
        sleepMet &&
        supplementsTaken &&
        photoTaken &&
        journaled
    }
    
    var dayNumber: Int {
        guard let startDate = UserDefaults.standard.object(forKey: "challengeStartDate") as? Date else {
            return 1
        }
        return Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 1
    }
    
    init(
        date: Date,
        read: Bool = false,
        workoutsCompleted: Int = 0,
        waterDrank: Bool = false,
        sleepMet: Bool = false,
        supplementsTaken: Bool = false,
        photoTaken: Bool = false,
        journaled: Bool = false,
        journalEntry: JournalEntry? = nil,
        workoutDay: WorkoutDay? = nil
    ) {
        self.date = date
        self.read = read
        self.workoutsCompleted = workoutsCompleted
        self.waterDrank = waterDrank
        self.sleepMet = sleepMet
        self.supplementsTaken = supplementsTaken
        self.photoTaken = photoTaken
        self.journaled = journaled
        self.journalEntry = journalEntry
        self.workoutDay = workoutDay
    }
}