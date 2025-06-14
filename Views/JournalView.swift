import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [JournalEntry]
    
    @State private var morningEntry = ""
    @State private var eveningEntry = ""
    @State private var weeklyResponse = ""
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var currentEntry: JournalEntry? {
        entries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Morning Section
                VStack(alignment: .leading) {
                    Text("Morning Reflection")
                        .font(.titleMedium)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $morningEntry)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Evening Section
                VStack(alignment: .leading) {
                    Text("Evening Reflection")
                        .font(.titleMedium)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $eveningEntry)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Weekly Prompt Section
                VStack(alignment: .leading) {
                    Text("Weekly Prompt")
                        .font(.titleMedium)
                        .fontWeight(.medium)
                    
                    Text(PromptManager.shared.getPromptForWeek())
                        .font(.bodyText)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
                    TextEditor(text: $weeklyResponse)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Button("Save Journal Entry") {
                    saveEntry()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .onAppear {
            loadExistingEntry()
        }
    }
    
    private func loadExistingEntry() {
        if let entry = currentEntry {
            morningEntry = entry.morningEntry
            eveningEntry = entry.eveningEntry
            weeklyResponse = entry.weeklyResponse
        }
    }
    
    private func saveEntry() {
        if let entry = currentEntry {
            entry.morningEntry = morningEntry
            entry.eveningEntry = eveningEntry
            entry.weeklyResponse = weeklyResponse
        } else {
            let newEntry = JournalEntry(
                date: today,
                morningEntry: morningEntry,
                eveningEntry: eveningEntry,
                weeklyPrompt: PromptManager.shared.getPromptForWeek(),
                weeklyResponse: weeklyResponse
            )
            modelContext.insert(newEntry)
        }
        
        // Update the checklist
        if let checklist = try? modelContext.fetch(FetchDescriptor<DailyChecklist>(
            predicate: #Predicate<DailyChecklist> { $0.date == today }
        )).first {
            checklist.journaled = true
        }
        
        try? modelContext.save()
    }
}
