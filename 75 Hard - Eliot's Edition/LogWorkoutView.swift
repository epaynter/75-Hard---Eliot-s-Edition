import SwiftUI
import SwiftData

struct LogWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var workoutType = "Strength"
    @State private var duration = ""
    @State private var notes = ""
    
    private let workoutTypes = ["Strength", "Cardio", "HIIT", "Yoga", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Details") {
                    Picker("Type", selection: $workoutType) {
                        ForEach(workoutTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    TextField("Duration (minutes)", text: $duration)
                        .keyboardType(.numberPad)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Save workout entry
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    LogWorkoutView()
} 