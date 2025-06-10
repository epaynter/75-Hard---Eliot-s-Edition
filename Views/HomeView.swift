import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ChecklistViewModel
    @State private var showingPhotoPicker = false
    @State private var showingJournal = false
    
    init() {
        _viewModel = State(initialValue: ChecklistViewModel(modelContext: ModelContext.shared))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress Section
                    VStack(spacing: 16) {
                        Text("Day \(dayNumber()) of 75")
                            .font(.largeTitle)
                            .bold()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: progress())
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                            
                            VStack {
                                Text("\(Int(progress() * 100))%")
                                    .font(.title)
                                    .bold()
                                Text("Complete")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top)
                    
                    // Quick Actions
                    HStack(spacing: 20) {
                        QuickActionButton(
                            title: "Take Photo",
                            systemImage: "camera.fill",
                            color: .blue
                        ) {
                            showingPhotoPicker = true
                        }
                        
                        QuickActionButton(
                            title: "Journal",
                            systemImage: "book.fill",
                            color: .green
                        ) {
                            showingJournal = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Checklist Section
                    VStack(spacing: 16) {
                        Text("Today's Tasks")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            checklistToggle(title: "Read 10 Pages", keyPath: \.read)
                            checklistToggle(title: "Workouts Completed", keyPath: \.workoutsCompleted)
                            checklistToggle(title: "Drank 1 Gallon Water", keyPath: \.waterDrank)
                            checklistToggle(title: "7+ Hours Sleep", keyPath: \.sleepMet)
                            checklistToggle(title: "Supplements Taken", keyPath: \.supplementsTaken)
                            checklistToggle(title: "Photo Taken", keyPath: \.photoTaken)
                            checklistToggle(title: "Journaled", keyPath: \.journaled)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("75 Hard")
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPickerView()
            }
            .sheet(isPresented: $showingJournal) {
                JournalView()
            }
            .onAppear {
                viewModel.loadOrCreateTodayChecklist()
            }
        }
    }
    
    func dayNumber() -> Int {
        guard let startDate = Calendar.current.date(byAdding: .day, value: -viewModelOffset(), to: Date()) else {
            return 1
        }
        return Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
    }
    
    func viewModelOffset() -> Int {
        // Get start date from UserDefaults
        if let startDate = UserDefaults.standard.object(forKey: "challengeStartDate") as? Date {
            return Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        }
        return 0
    }
    
    func progress() -> Double {
        return Double(dayNumber()) / 75.0
    }
    
    @ViewBuilder
    func checklistToggle(title: String, keyPath: WritableKeyPath<DailyChecklist, Bool>) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let checklist = viewModel.todayChecklist {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleChecklistItem(keyPath)
                    }
                }) {
                    Image(systemName: checklist[keyPath: keyPath] ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(checklist[keyPath: keyPath] ? .green : .gray)
                        .imageScale(.large)
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}