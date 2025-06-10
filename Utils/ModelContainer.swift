import SwiftUI
import SwiftData

@MainActor
class ModelContainer {
    static let shared = ModelContainer()
    
    let container: ModelContainer
    let context: ModelContext
    
    private init() {
        let schema = Schema([
            DailyChecklist.self,
            JournalEntry.self,
            WorkoutDay.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            context = container.mainContext
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        context.delete(model)
        save()
    }
    
    func deleteAll<T: PersistentModel>(_ modelType: T.Type) {
        do {
            try context.delete(model: modelType)
            save()
        } catch {
            print("Error deleting all \(modelType): \(error)")
        }
    }
} 