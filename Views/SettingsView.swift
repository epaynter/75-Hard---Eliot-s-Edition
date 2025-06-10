import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("challengeStartDate") private var challengeStartDate = Date()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("waterRemindersEnabled") private var waterRemindersEnabled = true
    @AppStorage("journalRemindersEnabled") private var journalRemindersEnabled = true
    @AppStorage("photoRemindersEnabled") private var photoRemindersEnabled = true
    
    @State private var showingResetAlert = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            Form {
                Section("Challenge Settings") {
                    DatePicker("Start Date", selection: $challengeStartDate, displayedComponents: .date)
                        .onChange(of: challengeStartDate) { _, _ in
                            UserDefaults.standard.set(challengeStartDate, forKey: "challengeStartDate")
                        }
                }
                
                Section("Notifications") {
                    Toggle("Enable All Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                Task {
                                    await requestNotificationPermissions()
                                }
                            } else {
                                NotificationManager.shared.removeAllNotifications()
                            }
                        }
                    
                    if notificationsEnabled {
                        Toggle("Water Reminders", isOn: $waterRemindersEnabled)
                        Toggle("Journal Reminders", isOn: $journalRemindersEnabled)
                        Toggle("Photo Reminders", isOn: $photoRemindersEnabled)
                    }
                }
                
                Section {
                    Button("Reset Progress", role: .destructive) {
                        showingResetAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("This will delete all your progress data. This action cannot be undone.")
            }
        }
    }
    
    private func requestNotificationPermissions() async {
        do {
            try await NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleNotifications()
        } catch {
            print("Failed to request notification permissions: \(error)")
        }
    }
    
    private func resetProgress() {
        // Delete all SwiftData models
        try? modelContext.delete(model: DailyChecklist.self)
        try? modelContext.delete(model: JournalEntry.self)
        
        // Delete all photos
        try? PhotoManager.shared.deleteAllPhotos()
        
        // Reset start date to today
        challengeStartDate = Date()
    }
}
