//
//  CalendarView.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date?
    @State private var showingDayDetail = false
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10)) ?? Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("75 Hard Progress")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(viewModel.completedDays) of 75 days completed")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Overall Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Overall Progress")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(viewModel.overallProgress * 100))%")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        ProgressView(value: viewModel.overallProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Calendar Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        // Day headers
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                        
                        // Calendar days
                        ForEach(viewModel.calendarDays, id: \.date) { dayData in
                            CalendarDayView(
                                dayData: dayData,
                                isToday: Calendar.current.isDateInToday(dayData.date)
                            ) {
                                selectedDate = dayData.date
                                showingDayDetail = true
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Streak Info
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(viewModel.currentStreak)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Current Streak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(viewModel.longestStreak)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Longest Streak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.loadCalendarData(startDate: startDate)
            }
            .sheet(isPresented: $showingDayDetail) {
                if let selectedDate = selectedDate {
                    DayDetailView(date: selectedDate)
                }
            }
        }
    }
}

struct CalendarDayView: View {
    let dayData: CalendarDayData
    let isToday: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: dayData.date))")
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .regular)
                
                Image(systemName: dayData.status.iconName)
                    .font(.caption2)
                    .foregroundColor(dayData.status.color)
            }
            .frame(width: 40, height: 40)
            .background(isToday ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let date: Date
    @State private var checklist: DailyChecklist?
    @State private var journal: JournalEntry?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text(date, style: .date)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let checklist = checklist {
                            Text("\(Int(checklist.completionPercentage * 100))% Complete")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // Habits
                    if let checklist = checklist {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Habits")
                                .font(.headline)
                            
                            HabitStatusRow(title: "Read 10 pages", completed: checklist.hasRead)
                            HabitStatusRow(title: "Workouts (\(checklist.workoutsCompleted)/2)", completed: checklist.workoutsCompleted >= 2)
                            HabitStatusRow(title: "Water", completed: checklist.hasWater)
                            HabitStatusRow(title: "7+ hours sleep", completed: checklist.hasSleep)
                            HabitStatusRow(title: "Supplements", completed: checklist.hasSupplements)
                            HabitStatusRow(title: "Photo taken", completed: checklist.hasPhoto)
                            HabitStatusRow(title: "Journaled", completed: checklist.hasJournaled)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Journal
                    if let journal = journal, (!journal.morningText.isEmpty || !journal.eveningText.isEmpty) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Journal Entry")
                                .font(.headline)
                            
                            if !journal.morningText.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Morning")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                    Text(journal.morningText)
                                        .font(.body)
                                }
                            }
                            
                            if !journal.eveningText.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Evening")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.purple)
                                    Text(journal.eveningText)
                                        .font(.body)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Day Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadDayData()
            }
        }
    }
    
    private func loadDayData() {
        let dayStart = Calendar.current.startOfDay(for: date)
        
        // Load checklist
        let checklistPredicate = #Predicate<DailyChecklist> { checklist in
            Calendar.current.isDate(checklist.date, inSameDayAs: dayStart)
        }
        let checklistDescriptor = FetchDescriptor<DailyChecklist>(predicate: checklistPredicate)
        
        // Load journal
        let journalPredicate = #Predicate<JournalEntry> { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: dayStart)
        }
        let journalDescriptor = FetchDescriptor<JournalEntry>(predicate: journalPredicate)
        
        do {
            let checklists = try modelContext.fetch(checklistDescriptor)
            checklist = checklists.first
            
            let journals = try modelContext.fetch(journalDescriptor)
            journal = journals.first
        } catch {
            print("Error loading day data: \(error)")
        }
    }
}

struct HabitStatusRow: View {
    let title: String
    let completed: Bool
    
    var body: some View {
        HStack {
            Image(systemName: completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(completed ? .green : .red)
            Text(title)
            Spacer()
        }
    }
}

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var calendarDays: [CalendarDayData] = []
    @Published var completedDays = 0
    @Published var currentStreak = 0
    @Published var longestStreak = 0
    @Published var overallProgress: Double = 0
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func loadCalendarData(startDate: Date) {
        guard let modelContext = modelContext else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate days for 75 hard challenge
        var days: [CalendarDayData] = []
        
        for i in 0..<75 {
            guard let date = calendar.date(byAdding: .day, value: i, to: startDate) else { continue }
            
            let status: DayStatus
            if date > today {
                status = .upcoming
            } else {
                // Check if day was completed
                let dayStart = calendar.startOfDay(for: date)
                let predicate = #Predicate<DailyChecklist> { checklist in
                    Calendar.current.isDate(checklist.date, inSameDayAs: dayStart)
                }
                let descriptor = FetchDescriptor<DailyChecklist>(predicate: predicate)
                
                do {
                    let checklists = try modelContext.fetch(descriptor)
                    if let checklist = checklists.first {
                        status = checklist.completionPercentage >= 0.8 ? .completed : .missed
                    } else {
                        status = .missed
                    }
                } catch {
                    status = .missed
                }
            }
            
            days.append(CalendarDayData(date: date, status: status))
        }
        
        calendarDays = days
        calculateStats()
    }
    
    private func calculateStats() {
        let completed = calendarDays.filter { $0.status == .completed }
        completedDays = completed.count
        overallProgress = Double(completedDays) / 75.0
        
        // Calculate streaks
        var current = 0
        var longest = 0
        var tempStreak = 0
        
        for day in calendarDays {
            if day.status == .completed {
                tempStreak += 1
                longest = max(longest, tempStreak)
            } else if day.status == .missed {
                tempStreak = 0
            }
        }
        
        // Calculate current streak from the end
        for day in calendarDays.reversed() {
            if day.status == .completed && day.date <= Date() {
                current += 1
            } else if day.status == .missed {
                break
            }
        }
        
        currentStreak = current
        longestStreak = longest
    }
}

struct CalendarDayData {
    let date: Date
    let status: DayStatus
}

enum DayStatus {
    case completed
    case missed
    case upcoming
    
    var iconName: String {
        switch self {
        case .completed: return "checkmark.circle.fill"
        case .missed: return "xmark.circle.fill"
        case .upcoming: return "circle"
        }
    }
    
    var color: Color {
        switch self {
        case .completed: return .green
        case .missed: return .red
        case .upcoming: return .gray
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self], inMemory: true)
}