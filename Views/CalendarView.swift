import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var checklists: [DailyChecklist]
    @Query private var journalEntries: [JournalEntry]
    
    @State private var selectedDate: Date?
    @State private var showingDetail = false
    
    private let calendar = Calendar.current
    private let startDate: Date
    
    init() {
        // Get the start date from UserDefaults or use today
        if let savedDate = UserDefaults.standard.object(forKey: "challengeStartDate") as? Date {
            startDate = calendar.startOfDay(for: savedDate)
        } else {
            startDate = calendar.startOfDay(for: Date())
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<75) { day in
                    let date = calendar.date(byAdding: .day, value: day, to: startDate)!
                    DayCell(date: date, checklist: checklistForDate(date))
                        .onTapGesture {
                            selectedDate = date
                            showingDetail = true
                        }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingDetail) {
            if let date = selectedDate {
                DayDetailView(
                    date: date,
                    checklist: checklistForDate(date),
                    journalEntry: journalEntryForDate(date)
                )
            }
        }
    }
    
    private func checklistForDate(_ date: Date) -> DailyChecklist? {
        checklists.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func journalEntryForDate(_ date: Date) -> JournalEntry? {
        journalEntries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

struct DayCell: View {
    let date: Date
    let checklist: DailyChecklist?
    
    private var isCompleted: Bool {
        guard let checklist = checklist else { return false }
        return checklist.read &&
               checklist.workoutsCompleted >= 2 &&
               checklist.waterDrank &&
               checklist.sleepMet &&
               checklist.supplementsTaken &&
               checklist.photoTaken &&
               checklist.journaled
    }
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if checklist != nil {
                Image(systemName: "circle.fill")
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 50)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct DayDetailView: View {
    let date: Date
    let checklist: DailyChecklist?
    let journalEntry: JournalEntry?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Checklist Status
                    if let checklist = checklist {
                        VStack(alignment: .leading) {
                            Text("Daily Tasks")
                                .font(.headline)
                            
                            TaskRow(title: "Read", isCompleted: checklist.read)
                            TaskRow(title: "Workouts", isCompleted: checklist.workoutsCompleted >= 2)
                            TaskRow(title: "Water", isCompleted: checklist.waterDrank)
                            TaskRow(title: "Sleep", isCompleted: checklist.sleepMet)
                            TaskRow(title: "Supplements", isCompleted: checklist.supplementsTaken)
                            TaskRow(title: "Photo", isCompleted: checklist.photoTaken)
                            TaskRow(title: "Journal", isCompleted: checklist.journaled)
                        }
                    }
                    
                    // Journal Entry
                    if let entry = journalEntry {
                        VStack(alignment: .leading) {
                            Text("Journal Entry")
                                .font(.headline)
                            
                            if !entry.morningEntry.isEmpty {
                                Text("Morning Reflection")
                                    .font(.subheadline)
                                Text(entry.morningEntry)
                                    .padding(.bottom)
                            }
                            
                            if !entry.eveningEntry.isEmpty {
                                Text("Evening Reflection")
                                    .font(.subheadline)
                                Text(entry.eveningEntry)
                                    .padding(.bottom)
                            }
                            
                            if !entry.weeklyResponse.isEmpty {
                                Text("Weekly Prompt")
                                    .font(.subheadline)
                                Text(entry.weeklyPrompt)
                                    .foregroundColor(.secondary)
                                Text(entry.weeklyResponse)
                            }
                        }
                    }
                    
                    // Progress Photo
                    if let checklist = checklist, checklist.photoTaken {
                        VStack(alignment: .leading) {
                            Text("Progress Photo")
                                .font(.headline)
                            
                            if let image = PhotoManager.shared.loadPhoto(for: date) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TaskRow: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
            Text(title)
            Spacer()
        }
    }
}
