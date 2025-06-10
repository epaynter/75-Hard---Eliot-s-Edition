

import Foundation
import SwiftData
import Observation

@Observable
class ChecklistViewModel {
    private let modelContext: ModelContext
    @Published var todayChecklist: DailyChecklist?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateTodayChecklist()
    }

    func loadOrCreateTodayChecklist() {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyChecklist>(
            predicate: #Predicate { $0.date == today },
            sortBy: [.init(\.date)]
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            self.todayChecklist = existing
        } else {
            let newChecklist = DailyChecklist(date: today)
            modelContext.insert(newChecklist)
            self.todayChecklist = newChecklist
        }
    }

    func toggleChecklistItem(_ keyPath: WritableKeyPath<DailyChecklist, Bool>) {
        guard let checklist = todayChecklist else { return }
        checklist[keyPath: keyPath].toggle()
    }

    func incrementWorkoutCount() {
        guard let checklist = todayChecklist else { return }
        checklist.workoutsCompleted += 1
    }

    func resetWorkoutCount() {
        guard let checklist = todayChecklist else { return }
        checklist.workoutsCompleted = 0
    }
}