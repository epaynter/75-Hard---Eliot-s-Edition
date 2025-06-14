import SwiftUI
import SwiftData

struct LogProteinView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var proteinAmount = ""
    @State private var selectedMeal = "Breakfast"
    
    private let meals = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Protein Amount") {
                    TextField("Enter grams", text: $proteinAmount)
                        .keyboardType(.numberPad)
                }
                
                Section("Meal") {
                    Picker("Select Meal", selection: $selectedMeal) {
                        ForEach(meals, id: \.self) { meal in
                            Text(meal).tag(meal)
                        }
                    }
                }
            }
            .navigationTitle("Log Protein")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Save protein entry
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    LogProteinView()
} 