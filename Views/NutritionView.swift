import SwiftUI
import SwiftData

struct NutritionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NutritionViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Nutrition Tracking")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(Date(), style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Goals Overview (if configured)
                    if let goals = viewModel.nutritionGoals, goals.hasAnyGoals {
                        NutritionGoalsCard(
                            goals: goals,
                            summary: viewModel.dailySummary
                        )
                    }
                    
                    // Quick Entry Section
                    NutritionQuickEntryCard(viewModel: viewModel)
                    
                    // Today's Entries
                    if !viewModel.todaysEntries.isEmpty {
                        NutritionEntriesCard(
                            entries: viewModel.todaysEntries,
                            onDelete: viewModel.deleteEntry
                        )
                    }
                    
                    // Goals Configuration
                    NutritionGoalsConfigCard(
                        goals: viewModel.nutritionGoals,
                        onUpdate: viewModel.updateGoals
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.loadTodaysData()
            }
        }
    }
}

struct NutritionGoalsCard: View {
    let goals: NutritionGoals
    let summary: DailyNutritionSummary?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Progress")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                if let calories = goals.dailyCalories {
                    NutritionProgressRow(
                        title: "Calories",
                        current: summary?.totalCalories ?? 0,
                        goal: Double(calories),
                        unit: "cal",
                        color: .orange
                    )
                }
                
                if let protein = goals.dailyProtein {
                    NutritionProgressRow(
                        title: "Protein",
                        current: summary?.totalProtein ?? 0,
                        goal: protein,
                        unit: "g",
                        color: .red
                    )
                }
                
                if let carbs = goals.dailyCarbs {
                    NutritionProgressRow(
                        title: "Carbs",
                        current: summary?.totalCarbs ?? 0,
                        goal: carbs,
                        unit: "g",
                        color: .blue
                    )
                }
                
                if let fat = goals.dailyFat {
                    NutritionProgressRow(
                        title: "Fat",
                        current: summary?.totalFat ?? 0,
                        goal: fat,
                        unit: "g",
                        color: .yellow
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct NutritionProgressRow: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    
    var progress: Double {
        goal > 0 ? min(current / goal, 1.0) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(current))/\(Int(goal)) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: max(0, progress * 250), height: 8)
                    .animation(.spring(response: 0.5), value: progress)
            }
            .frame(maxWidth: 250)
        }
    }
}

struct NutritionQuickEntryCard: View {
    @ObservedObject var viewModel: NutritionViewModel
    @State private var showingDetailEntry = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Add")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Protein quick entry
                QuickNutritionEntry(
                    title: "Protein",
                    placeholder: "40g",
                    color: .red,
                    unit: "g"
                ) { amount in
                    viewModel.addQuickEntry(protein: amount)
                }
                
                // Calories quick entry
                QuickNutritionEntry(
                    title: "Calories",
                    placeholder: "500 cal",
                    color: .orange,
                    unit: "cal"
                ) { amount in
                    viewModel.addQuickEntry(calories: amount)
                }
                
                // Detailed entry button
                Button("Add Detailed Entry") {
                    showingDetailEntry = true
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .sheet(isPresented: $showingDetailEntry) {
            DetailedNutritionEntryView { entry in
                viewModel.addDetailedEntry(entry)
            }
        }
    }
}

struct QuickNutritionEntry: View {
    let title: String
    let placeholder: String
    let color: Color
    let unit: String
    let onAdd: (Double) -> Void
    
    @State private var input = ""
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)
            
            TextField(placeholder, text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            Button("Add") {
                if let amount = Double(input.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    onAdd(amount)
                    input = ""
                }
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
            )
            .disabled(input.isEmpty)
        }
    }
}

struct NutritionEntriesCard: View {
    let entries: [NutritionEntry]
    let onDelete: (NutritionEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Entries")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(entries, id: \.id) { entry in
                    NutritionEntryRow(entry: entry) {
                        onDelete(entry)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct NutritionEntryRow: View {
    let entry: NutritionEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if !entry.foodItem.isEmpty {
                    Text(entry.foodItem)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 8) {
                    if entry.calories > 0 {
                        NutritionBadge(value: entry.calories, unit: "cal", color: .orange)
                    }
                    if entry.protein > 0 {
                        NutritionBadge(value: entry.protein, unit: "g protein", color: .red)
                    }
                    if entry.carbs > 0 {
                        NutritionBadge(value: entry.carbs, unit: "g carbs", color: .blue)
                    }
                    if entry.fat > 0 {
                        NutritionBadge(value: entry.fat, unit: "g fat", color: .yellow)
                    }
                }
            }
            
            Spacer()
            
            Button("Remove") {
                onDelete()
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

struct NutritionBadge: View {
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        Text("\(Int(value)) \(unit)")
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
            )
    }
}

struct NutritionGoalsConfigCard: View {
    let goals: NutritionGoals?
    let onUpdate: (NutritionGoals) -> Void
    @State private var showingConfig = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goals Configuration")
                .font(.headline)
                .fontWeight(.bold)
            
            if let goals = goals, goals.hasAnyGoals {
                VStack(alignment: .leading, spacing: 8) {
                    if let calories = goals.dailyCalories {
                        Text("Daily Calories: \(calories)")
                            .font(.subheadline)
                    }
                    if let protein = goals.dailyProtein {
                        Text("Daily Protein: \(Int(protein))g")
                            .font(.subheadline)
                    }
                    if let carbs = goals.dailyCarbs {
                        Text("Daily Carbs: \(Int(carbs))g")
                            .font(.subheadline)
                    }
                    if let fat = goals.dailyFat {
                        Text("Daily Fat: \(Int(fat))g")
                            .font(.subheadline)
                    }
                }
                .foregroundColor(.secondary)
            } else {
                Text("No nutrition goals configured")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button(goals?.hasAnyGoals == true ? "Update Goals" : "Set Goals") {
                showingConfig = true
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .sheet(isPresented: $showingConfig) {
            NutritionGoalsConfigView(goals: goals) { newGoals in
                onUpdate(newGoals)
            }
        }
    }
}

struct DetailedNutritionEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (NutritionEntry) -> Void
    
    @State private var foodItem = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Food Item") {
                    TextField("e.g., Chicken Breast - 6oz", text: $foodItem)
                }
                
                Section("Nutrition Info") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let entry = NutritionEntry(
                            date: Date(),
                            foodItem: foodItem,
                            calories: Double(calories) ?? 0,
                            protein: Double(protein) ?? 0,
                            carbs: Double(carbs) ?? 0,
                            fat: Double(fat) ?? 0,
                            isQuickEntry: false
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(foodItem.isEmpty && calories.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct NutritionGoalsConfigView: View {
    @Environment(\.dismiss) private var dismiss
    let goals: NutritionGoals?
    let onSave: (NutritionGoals) -> Void
    
    @State private var dailyCalories: String
    @State private var dailyProtein: String
    @State private var dailyCarbs: String
    @State private var dailyFat: String
    @State private var enableCalories: Bool
    @State private var enableProtein: Bool
    @State private var enableCarbs: Bool
    @State private var enableFat: Bool
    
    init(goals: NutritionGoals?, onSave: @escaping (NutritionGoals) -> Void) {
        self.goals = goals
        self.onSave = onSave
        
        _dailyCalories = State(initialValue: goals?.dailyCalories.map(String.init) ?? "2000")
        _dailyProtein = State(initialValue: goals?.dailyProtein.map { String(Int($0)) } ?? "150")
        _dailyCarbs = State(initialValue: goals?.dailyCarbs.map { String(Int($0)) } ?? "200")
        _dailyFat = State(initialValue: goals?.dailyFat.map { String(Int($0)) } ?? "80")
        
        _enableCalories = State(initialValue: goals?.dailyCalories != nil)
        _enableProtein = State(initialValue: goals?.dailyProtein != nil)
        _enableCarbs = State(initialValue: goals?.dailyCarbs != nil)
        _enableFat = State(initialValue: goals?.dailyFat != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Configure Your Daily Goals") {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Track Calories", isOn: $enableCalories)
                        if enableCalories {
                            HStack {
                                Text("Daily Calories")
                                Spacer()
                                TextField("2000", text: $dailyCalories)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        
                        Toggle("Track Protein", isOn: $enableProtein)
                        if enableProtein {
                            HStack {
                                Text("Daily Protein (g)")
                                Spacer()
                                TextField("150", text: $dailyProtein)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        
                        Toggle("Track Carbs", isOn: $enableCarbs)
                        if enableCarbs {
                            HStack {
                                Text("Daily Carbs (g)")
                                Spacer()
                                TextField("200", text: $dailyCarbs)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        
                        Toggle("Track Fat", isOn: $enableFat)
                        if enableFat {
                            HStack {
                                Text("Daily Fat (g)")
                                Spacer()
                                TextField("80", text: $dailyFat)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nutrition Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newGoals = NutritionGoals(
                            dailyCalories: enableCalories ? Int(dailyCalories) : nil,
                            dailyProtein: enableProtein ? Double(dailyProtein) : nil,
                            dailyCarbs: enableCarbs ? Double(dailyCarbs) : nil,
                            dailyFat: enableFat ? Double(dailyFat) : nil
                        )
                        onSave(newGoals)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

@MainActor
class NutritionViewModel: ObservableObject {
    @Published var nutritionGoals: NutritionGoals?
    @Published var todaysEntries: [NutritionEntry] = []
    @Published var dailySummary: DailyNutritionSummary?
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func loadTodaysData() {
        loadNutritionGoals()
        loadTodaysEntries()
        updateDailySummary()
    }
    
    private func loadNutritionGoals() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<NutritionGoals>(
            predicate: #Predicate { $0.isActive }
        )
        
        do {
            let goals = try modelContext.fetch(descriptor)
            nutritionGoals = goals.first
        } catch {
            print("❌ Error loading nutrition goals: \(error)")
        }
    }
    
    private func loadTodaysEntries() {
        guard let modelContext = modelContext else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let predicate = #Predicate<NutritionEntry> { entry in
            entry.date >= today && entry.date < tomorrow
        }
        
        let descriptor = FetchDescriptor<NutritionEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            todaysEntries = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error loading nutrition entries: \(error)")
        }
    }
    
    private func updateDailySummary() {
        guard let modelContext = modelContext else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // Find or create daily summary
        let predicate = #Predicate<DailyNutritionSummary> { summary in
            summary.date == today
        }
        
        let descriptor = FetchDescriptor<DailyNutritionSummary>(predicate: predicate)
        
        do {
            let summaries = try modelContext.fetch(descriptor)
            let summary = summaries.first ?? DailyNutritionSummary(date: today)
            
            if summaries.isEmpty {
                modelContext.insert(summary)
            }
            
            summary.updateFromEntries(todaysEntries)
            try modelContext.save()
            
            dailySummary = summary
        } catch {
            print("❌ Error updating daily summary: \(error)")
        }
    }
    
    func addQuickEntry(calories: Double = 0, protein: Double = 0, carbs: Double = 0, fat: Double = 0) {
        guard let modelContext = modelContext else { return }
        
        let entry = NutritionEntry(
            date: Date(),
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            isQuickEntry: true
        )
        
        modelContext.insert(entry)
        
        do {
            try modelContext.save()
            loadTodaysEntries()
            updateDailySummary()
        } catch {
            print("❌ Error saving nutrition entry: \(error)")
        }
    }
    
    func addDetailedEntry(_ entry: NutritionEntry) {
        guard let modelContext = modelContext else { return }
        
        modelContext.insert(entry)
        
        do {
            try modelContext.save()
            loadTodaysEntries()
            updateDailySummary()
        } catch {
            print("❌ Error saving detailed nutrition entry: \(error)")
        }
    }
    
    func deleteEntry(_ entry: NutritionEntry) {
        guard let modelContext = modelContext else { return }
        
        modelContext.delete(entry)
        
        do {
            try modelContext.save()
            loadTodaysEntries()
            updateDailySummary()
        } catch {
            print("❌ Error deleting nutrition entry: \(error)")
        }
    }
    
    func updateGoals(_ goals: NutritionGoals) {
        guard let modelContext = modelContext else { return }
        
        // Deactivate existing goals
        if let existing = nutritionGoals {
            existing.isActive = false
        }
        
        modelContext.insert(goals)
        
        do {
            try modelContext.save()
            nutritionGoals = goals
        } catch {
            print("❌ Error updating nutrition goals: \(error)")
        }
    }
}

#Preview {
    NutritionView()
        .modelContainer(for: [NutritionGoals.self, NutritionEntry.self, DailyNutritionSummary.self], inMemory: true)
}