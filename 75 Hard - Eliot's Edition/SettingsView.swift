//
//  SettingsView.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var checklistViewModel = ChecklistViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingResetAlert = false
    @State private var showingAddSupplement = false
    @State private var showingChallengeConfig = false
    @State private var supplements: [Supplement] = []
    @State private var challengeSettings: ChallengeSettings?
    
    // New supplement form
    @State private var newSupplementName = ""
    @State private var newSupplementDosage = ""
    @State private var newSupplementTime: SupplementTime = .morning
    
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.purple, Color.blue]
                : [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "gear")
                                .font(.system(size: 50))
                                .foregroundStyle(headerGradient)
                            
                            Text("Settings")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .padding(.top)
                        
                        // Challenge Configuration
                        ChallengeConfigCard(
                            challengeSettings: challengeSettings,
                            showingChallengeConfig: $showingChallengeConfig
                        )
                        
                        // Notifications
                        NotificationCard(notificationManager: notificationManager)
                        
                        // Supplements Management
                        SupplementsCard(
                            supplements: supplements,
                            showingAddSupplement: $showingAddSupplement,
                            onDelete: deleteSupplement
                        )
                        
                        // Data Management
                        DataManagementCard(showingResetAlert: $showingResetAlert)
                        
                        // App Information
                        AppInfoCard()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
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
                loadSettings()
                // Set up checklist view model for supplement updates
                checklistViewModel.setModelContext(modelContext)
            }
            .sheet(isPresented: $showingAddSupplement) {
                AddSupplementView(
                    name: $newSupplementName,
                    dosage: $newSupplementDosage,
                    timeOfDay: $newSupplementTime,
                    onSave: addSupplement
                )
            }
            .sheet(isPresented: $showingChallengeConfig) {
                ChallengeConfigView(challengeSettings: challengeSettings) { newSettings in
                    challengeSettings = newSettings
                    saveChallengeSettings()
                }
            }
            .alert("Reset All Progress", isPresented: $showingResetAlert) {
                Button("Reset Everything", role: .destructive) {
                    resetAllProgress()
                }
                Button("Reset Only Data", role: .destructive) {
                    resetDataOnly()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose what to reset:\n\n• Reset Everything: Deletes all data AND settings\n• Reset Only Data: Keeps challenge settings and supplements")
            }
        }
    }
    
    private func loadSettings() {
        // Load supplements
        let supplementDescriptor = FetchDescriptor<Supplement>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            supplements = try modelContext.fetch(supplementDescriptor)
        } catch {
            print("Error loading supplements: \(error)")
        }
        
        // Load challenge settings
        let settingsDescriptor = FetchDescriptor<ChallengeSettings>()
        do {
            let settings = try modelContext.fetch(settingsDescriptor)
            challengeSettings = settings.first
        } catch {
            print("Error loading challenge settings: \(error)")
        }
    }
    
    private func addSupplement() {
        guard !newSupplementName.isEmpty, !newSupplementDosage.isEmpty else { return }
        
        let supplement = Supplement(
            name: newSupplementName,
            dosage: newSupplementDosage,
            timeOfDay: newSupplementTime
        )
        
        modelContext.insert(supplement)
        
        do {
            try modelContext.save()
            supplements.append(supplement)
            
            // FIXED: Update supplements for current and future days
            checklistViewModel.updateSupplementsForCurrentAndFutureDays()
            
            // Reset form
            newSupplementName = ""
            newSupplementDosage = ""
            newSupplementTime = .morning
        } catch {
            print("Error saving supplement: \(error)")
        }
    }
    
    private func deleteSupplement(_ supplement: Supplement) {
        supplement.isActive = false
        
        do {
            try modelContext.save()
            supplements.removeAll { $0.id == supplement.id }
        } catch {
            print("Error deleting supplement: \(error)")
        }
    }
    
    private func saveChallengeSettings() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving challenge settings: \(error)")
        }
    }
    
    private func resetAllProgress() {
        do {
            // Delete all data
            let checklistDescriptor = FetchDescriptor<DailyChecklist>()
            let checklists = try modelContext.fetch(checklistDescriptor)
            for checklist in checklists {
                modelContext.delete(checklist)
            }
            
            let journalDescriptor = FetchDescriptor<JournalEntry>()
            let journals = try modelContext.fetch(journalDescriptor)
            for journal in journals {
                modelContext.delete(journal)
            }
            
            let supplementDescriptor = FetchDescriptor<Supplement>()
            let allSupplements = try modelContext.fetch(supplementDescriptor)
            for supplement in allSupplements {
                modelContext.delete(supplement)
            }
            
            let settingsDescriptor = FetchDescriptor<ChallengeSettings>()
            let allSettings = try modelContext.fetch(settingsDescriptor)
            for setting in allSettings {
                modelContext.delete(setting)
            }
            
            // NEW: Delete custom habits and their entries
            let customHabitDescriptor = FetchDescriptor<CustomHabit>()
            let customHabits = try modelContext.fetch(customHabitDescriptor)
            for habit in customHabits {
                modelContext.delete(habit)
            }
            
            let customHabitEntryDescriptor = FetchDescriptor<CustomHabitEntry>()
            let customHabitEntries = try modelContext.fetch(customHabitEntryDescriptor)
            for entry in customHabitEntries {
                modelContext.delete(entry)
            }
            
            try modelContext.save()
            
            // Reset local state
            supplements = []
            challengeSettings = nil
            
            // FIXED: Reset onboarding flag to return to onboarding screen
            hasCompletedOnboarding = false
            
            // Dismiss settings view to trigger app state change
            dismiss()
            
        } catch {
            print("Error resetting all progress: \(error)")
        }
    }
    
    private func resetDataOnly() {
        do {
            // Only delete progress data, keep settings and supplements
            let checklistDescriptor = FetchDescriptor<DailyChecklist>()
            let checklists = try modelContext.fetch(checklistDescriptor)
            for checklist in checklists {
                modelContext.delete(checklist)
            }
            
            let journalDescriptor = FetchDescriptor<JournalEntry>()
            let journals = try modelContext.fetch(journalDescriptor)
            for journal in journals {
                modelContext.delete(journal)
            }
            
            // NEW: Also reset custom habit entries (but keep the habit definitions)
            let customHabitEntryDescriptor = FetchDescriptor<CustomHabitEntry>()
            let customHabitEntries = try modelContext.fetch(customHabitEntryDescriptor)
            for entry in customHabitEntries {
                modelContext.delete(entry)
            }
            
            try modelContext.save()
            
        } catch {
            print("Error resetting data: \(error)")
        }
    }
}

struct ChallengeConfigCard: View {
    let challengeSettings: ChallengeSettings?
    @Binding var showingChallengeConfig: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Challenge Settings")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if let settings = challengeSettings {
                VStack(spacing: 12) {
                    HStack {
                        Text("Start Date")
                        Spacer()
                        Text(settings.startDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(settings.duration) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Water Goal")
                        Spacer()
                        Text("\(Int(settings.goalWaterOunces)) oz")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("End Date")
                        Spacer()
                        Text(settings.endDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No challenge configured")
                    .foregroundColor(.secondary)
            }
            
            Button("Configure Challenge") {
                showingChallengeConfig = true
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct NotificationCard: View {
    @ObservedObject var notificationManager: NotificationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Notifications")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Toggle("Daily Reminders", isOn: $notificationManager.notificationsEnabled)
                .font(.body)
                .fontWeight(.medium)
                .onChange(of: notificationManager.notificationsEnabled) { oldValue, newValue in
                    Task {
                        if newValue {
                            await notificationManager.enableNotifications()
                        } else {
                            await notificationManager.disableNotifications()
                        }
                    }
                }
            
            if notificationManager.notificationsEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Reminders:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 4) {
                        NotificationRow(time: "8:00 AM", title: "Morning Journal", icon: "sunrise.fill", color: .orange)
                        NotificationRow(time: "10:00 AM", title: "First Water Reminder", icon: "drop.fill", color: .cyan)
                        NotificationRow(time: "2:00 PM", title: "Midday Check-in", icon: "checkmark.circle", color: .green)
                        NotificationRow(time: "8:00 PM", title: "Evening Reflection", icon: "moon.fill", color: .purple)
                        NotificationRow(time: "10:00 PM", title: "Bedtime Reminder", icon: "bed.double.fill", color: .indigo)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct NotificationRow: View {
    let time: String
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
                .frame(width: 16)
            
            Text(time)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
                .frame(width: 60, alignment: .leading)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct SupplementsCard: View {
    let supplements: [Supplement]
    @Binding var showingAddSupplement: Bool
    let onDelete: (Supplement) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "pills.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Supplements")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Add") {
                    showingAddSupplement = true
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            }
            
            if supplements.isEmpty {
                Text("No supplements configured")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(supplements, id: \.id) { supplement in
                        SupplementRowView(supplement: supplement) {
                            onDelete(supplement)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct SupplementRowView: View {
    let supplement: Supplement
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(supplement.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Text(supplement.dosage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(supplement.timeOfDay.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button("Remove") {
                onDelete()
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
}

struct DataManagementCard: View {
    @Binding var showingResetAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "externaldrive.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Data Management")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                Text("Reset your progress to start fresh. This action cannot be undone.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Reset Progress") {
                    showingResetAlert = true
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct AppInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("App Information")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("2.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Created by")
                    Spacer()
                    Text("Eliot Paynter")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2025.06.10")
                        .foregroundColor(.secondary)
                }
            }
            .font(.body)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct AddSupplementView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var dosage: String
    @Binding var timeOfDay: SupplementTime
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Supplement Details") {
                    TextField("Name (e.g. Vitamin D)", text: $name)
                    TextField("Dosage (e.g. 1000mg)", text: $dosage)
                    
                    Picker("Time of Day", selection: $timeOfDay) {
                        ForEach(SupplementTime.allCases, id: \.self) { time in
                            Text(time.displayName).tag(time)
                        }
                    }
                }
            }
            .navigationTitle("Add Supplement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
}

struct ChallengeConfigView: View {
    @Environment(\.dismiss) private var dismiss
    let challengeSettings: ChallengeSettings?
    let onSave: (ChallengeSettings) -> Void
    
    @State private var startDate: Date
    @State private var duration: Int
    @State private var goalWaterOunces: Double
    @State private var userAffirmation: String
    @State private var journalMode: JournalMode
    
    init(challengeSettings: ChallengeSettings?, onSave: @escaping (ChallengeSettings) -> Void) {
        self.challengeSettings = challengeSettings
        self.onSave = onSave
        
        _startDate = State(initialValue: challengeSettings?.startDate ?? Date())
        _duration = State(initialValue: challengeSettings?.duration ?? 75)
        _goalWaterOunces = State(initialValue: challengeSettings?.goalWaterOunces ?? 128.0)
        _userAffirmation = State(initialValue: challengeSettings?.userAffirmation ?? "")
        _journalMode = State(initialValue: challengeSettings?.journalMode ?? .guidedPrompts)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Challenge Basics") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text("\(duration) days")
                                .foregroundColor(.secondary)
                        }
                        
                        // NEW: Proper 1-day increment slider
                        Slider(value: Binding(
                            get: { Double(duration) },
                            set: { duration = Int($0) }
                        ), in: 30...100, step: 1)
                        .accentColor(.blue)
                        
                        Text("Choose between 30-100 days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Water Goal") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Daily Water Goal")
                            Spacer()
                            Text("\(Int(goalWaterOunces)) oz")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $goalWaterOunces, in: 64...200, step: 8)
                            .accentColor(.cyan)
                        
                        // NEW: Show conversions
                        Text("\(Int(goalWaterOunces))oz = \(String(format: "%.1f", goalWaterOunces/128.0)) gal = \(Int(goalWaterOunces/8)) cups")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Personal Motivation") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why are you doing this challenge?")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("I'm doing this because...", text: $userAffirmation, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...5)
                        
                        Text("This will be used for motivation throughout your journey")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // NEW: Journal Mode Selection
                Section("Journaling Style") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose your journaling approach")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Picker("Journal Mode", selection: $journalMode) {
                            ForEach(JournalMode.allCases, id: \.self) { mode in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mode.displayName)
                                        .font(.body)
                                    Text(mode.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text("This setting can be changed later in Settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // NEW: Preview section for future start dates
                if startDate > Date() {
                    Section("Challenge Preview") {
                        let daysUntilStart = Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? 0
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your challenge starts in \(daysUntilStart) days")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text("End Date: \(Calendar.current.date(byAdding: .day, value: duration-1, to: startDate) ?? startDate, style: .date)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Challenge Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let settings = challengeSettings ?? ChallengeSettings(startDate: startDate, duration: duration)
                        settings.startDate = startDate
                        settings.duration = duration
                        settings.goalWaterOunces = goalWaterOunces
                        settings.userAffirmation = userAffirmation
                        settings.journalMode = journalMode
                        
                        onSave(settings)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self, Supplement.self, ChallengeSettings.self, NotificationPreference.self], inMemory: true)
}