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
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingResetAlert = false
    @State private var customSupplements = UserDefaults.standard.array(forKey: "custom_supplements") as? [String] ?? []
    @State private var newSupplementName = ""
    @State private var showingAddSupplement = false
    
    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section("Notifications") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                        Toggle("Daily Reminders", isOn: $notificationManager.notificationsEnabled)
                            .onChange(of: notificationManager.notificationsEnabled) { enabled in
                                Task {
                                    if enabled {
                                        await notificationManager.enableNotifications()
                                    } else {
                                        await notificationManager.disableNotifications()
                                    }
                                }
                            }
                    }
                    
                    if notificationManager.notificationsEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Scheduled Reminders:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            NotificationInfoRow(time: "8:00 AM", title: "Morning Journal")
                            NotificationInfoRow(time: "10:00 AM - 8:00 PM", title: "Water Reminders (every 2 hours)")
                            NotificationInfoRow(time: "8:00 PM", title: "Evening Reflection & Photo")
                            NotificationInfoRow(time: "10:00 PM", title: "Bedtime Reminder")
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Supplements Section
                Section("Supplement Stack") {
                    ForEach(customSupplements, id: \.self) { supplement in
                        HStack {
                            Image(systemName: "pills.fill")
                                .foregroundColor(.green)
                            Text(supplement)
                            Spacer()
                            Button("Remove") {
                                removeSuplement(supplement)
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        showingAddSupplement = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Supplement")
                        }
                    }
                }
                
                // Challenge Info Section
                Section("Challenge Information") {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)
                        Text("Start Date")
                        Spacer()
                        Text("June 10, 2025")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.red)
                        Text("End Date")
                        Spacer()
                        Text("August 23, 2025")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Challenge Duration")
                        Spacer()
                        Text("75 Days")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.red)
                            Text("Reset All Progress")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // App Info Section
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.purple)
                        Text("Built by")
                        Spacer()
                        Text("Eliot Paynter")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Add Supplement", isPresented: $showingAddSupplement) {
                TextField("Supplement name", text: $newSupplementName)
                Button("Add") {
                    addSupplement()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter the name of the supplement you want to track.")
            }
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    resetAllProgress()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your progress, journal entries, and photos. This action cannot be undone.")
            }
        }
    }
    
    private func addSupplement() {
        guard !newSupplementName.isEmpty else { return }
        customSupplements.append(newSupplementName)
        UserDefaults.standard.set(customSupplements, forKey: "custom_supplements")
        newSupplementName = ""
    }
    
    private func removeSuplement(_ supplement: String) {
        customSupplements.removeAll { $0 == supplement }
        UserDefaults.standard.set(customSupplements, forKey: "custom_supplements")
    }
    
    private func resetAllProgress() {
        do {
            // Delete all daily checklists
            let checklistDescriptor = FetchDescriptor<DailyChecklist>()
            let checklists = try modelContext.fetch(checklistDescriptor)
            for checklist in checklists {
                modelContext.delete(checklist)
            }
            
            // Delete all journal entries
            let journalDescriptor = FetchDescriptor<JournalEntry>()
            let journals = try modelContext.fetch(journalDescriptor)
            for journal in journals {
                modelContext.delete(journal)
            }
            
            try modelContext.save()
            
            // Reset UserDefaults
            UserDefaults.standard.removeObject(forKey: "custom_supplements")
            customSupplements = []
            
        } catch {
            print("Error resetting progress: \(error)")
        }
    }
}

struct NotificationInfoRow: View {
    let time: String
    let title: String
    
    var body: some View {
        HStack {
            Text(time)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 80, alignment: .leading)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self], inMemory: true)
}