//
//  JournalView.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = JournalViewModel()
    @State private var challengeSettings: ChallengeSettings?
    
    var currentJournalMode: JournalMode {
        challengeSettings?.journalMode ?? .guidedPrompts
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Daily Journal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(Date(), style: .date)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(currentJournalMode.displayName)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    .padding(.top)
                    
                    if currentJournalMode == .guidedPrompts {
                        // Morning Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sunrise.fill")
                                    .foregroundColor(.orange)
                                Text("Morning Reflection")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(viewModel.morningPrompt)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            TextEditor(text: $viewModel.morningText)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2, x: 0, y: 1)
                        
                        // Evening Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.purple)
                                Text("Evening Reflection")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(viewModel.eveningPrompt)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            TextEditor(text: $viewModel.eveningText)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2, x: 0, y: 1)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Free Writing")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Write freely about your day, thoughts, feelings, or anything that comes to mind.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            TextEditor(text: $viewModel.freeWriteText)
                                .frame(minHeight: 200)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2, x: 0, y: 1)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.loadTodaysEntry()
                loadChallengeSettings()
            }
        }
    }
    
    private func loadChallengeSettings() {
        let descriptor = FetchDescriptor<ChallengeSettings>()
        do {
            let settings = try modelContext.fetch(descriptor)
            challengeSettings = settings.first
        } catch {
            print("Error loading challenge settings in JournalView: \(error)")
        }
    }
}

@MainActor
class JournalViewModel: ObservableObject {
    @Published var morningText = ""
    @Published var eveningText = ""
    @Published var morningPrompt = ""
    @Published var eveningPrompt = ""
    @Published var freeWriteText = ""
    
    private var modelContext: ModelContext?
    private var currentEntry: JournalEntry?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func loadTodaysEntry() {
        guard let modelContext = modelContext else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let prompts = PromptManager.shared.getPromptsForDate(today)
        
        morningPrompt = prompts.morning
        eveningPrompt = prompts.evening
        
        let predicate = #Predicate<JournalEntry> { entry in
            entry.date >= today && entry.date < tomorrow
        }
        
        let descriptor = FetchDescriptor<JournalEntry>(predicate: predicate)
        
        do {
            let entries = try modelContext.fetch(descriptor)
            if let entry = entries.first {
                currentEntry = entry
                morningText = entry.morningText
                eveningText = entry.eveningText
                freeWriteText = entry.freeWriteText
            } else {
                // Create new entry for today
                let newEntry = JournalEntry(
                    date: today,
                    morningPrompt: prompts.morning,
                    eveningPrompt: prompts.evening
                )
                modelContext.insert(newEntry)
                currentEntry = newEntry
                try modelContext.save()
            }
        } catch {
            print("Error loading today's journal entry: \(error)")
        }
    }
    
    func saveEntry() {
        guard let modelContext = modelContext,
              let currentEntry = currentEntry else { return }
        
        currentEntry.morningText = morningText
        currentEntry.eveningText = eveningText
        currentEntry.freeWriteText = freeWriteText
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving journal entry: \(error)")
        }
    }
}

#Preview {
    JournalView()
        .modelContainer(for: [JournalEntry.self], inMemory: true)
}