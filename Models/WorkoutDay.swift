import Foundation
import SwiftData

@Model
class WorkoutDay {
    @Attribute(.unique) var date: Date
    var workoutType: WorkoutType
    var isCompleted: Bool
    var notes: String
    var duration: TimeInterval
    
    // Relationship
    @Relationship(inverse: \DailyChecklist.workoutDay) var checklist: DailyChecklist?
    
    // Computed properties
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    init(
        date: Date,
        workoutType: WorkoutType,
        isCompleted: Bool = false,
        notes: String = "",
        duration: TimeInterval = 0,
        checklist: DailyChecklist? = nil
    ) {
        self.date = date
        self.workoutType = workoutType
        self.isCompleted = isCompleted
        self.notes = notes
        self.duration = duration
        self.checklist = checklist
    }
}

enum WorkoutType: String, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case mobility = "Mobility"
    case yoga = "Yoga"
    case rehab = "Rehab"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .mobility: return "figure.flexibility"
        case .yoga: return "figure.mind.and.body"
        case .rehab: return "figure.walk"
        }
    }
    
    var color: String {
        switch self {
        case .strength: return "blue"
        case .cardio: return "red"
        case .mobility: return "green"
        case .yoga: return "purple"
        case .rehab: return "orange"
        }
    }
}
