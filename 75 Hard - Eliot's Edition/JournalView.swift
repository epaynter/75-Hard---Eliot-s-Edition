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
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = JournalViewModel()
    @State private var challengeSettings: ChallengeSettings?
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var isAnimating = false
    
    var currentJournalMode: JournalMode {
        challengeSettings?.journalMode ?? .guidedPrompts
    }
    
    var isToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }
    
    var compactDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: selectedDate)
    }
    
    // Premium gradients and colors
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.1)]
                : [Color(red: 0.98, green: 0.98, blue: 1.0), Color(red: 0.92, green: 0.92, blue: 0.98)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var cardGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.12, green: 0.12, blue: 0.16)]
                : [Color.white, Color(red: 0.99, green: 0.99, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Premium background
                    LinearGradient(
                        colors: colorScheme == .dark 
                            ? [Color(red: 0.02, green: 0.02, blue: 0.05), Color(red: 0.05, green: 0.05, blue: 0.08)]
                            : [Color(red: 0.96, green: 0.96, blue: 0.98), Color(red: 0.98, green: 0.98, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Elegant Header Section
                            VStack(spacing: 16) {
                                // Date Navigation Bar
                                HStack {
                                    // Previous Day
                                    Button {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                                            viewModel.loadEntryFor(date: selectedDate)
                                        }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.title2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .frame(width: 44, height: 44)
                                            .background(.ultraThinMaterial, in: Circle())
                                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    }
                                    
                                    Spacer()
                                    
                                    // Date Display
                                    VStack(spacing: 4) {
                                        Button {
                                            showingDatePicker = true
                                        } label: {
                                            VStack(spacing: 2) {
                                                Text(dateString)
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.center)
                                                
                                                if !isToday {
                                                    Text("Tap to select date")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        
                                        // Today indicator or Today button
                                        if isToday {
                                            Text("TODAY")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(
                                                    Capsule()
                                                        .fill(LinearGradient(
                                                            colors: [.blue, .purple],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        ))
                                                )
                                        } else {
                                            Button("Today") {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                    selectedDate = Date()
                                                    viewModel.loadEntryFor(date: selectedDate)
                                                }
                                            }
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(.blue.opacity(0.1))
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                                                    )
                                            )
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Next Day
                                    Button {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                                            viewModel.loadEntryFor(date: selectedDate)
                                        }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.title2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .frame(width: 44, height: 44)
                                            .background(.ultraThinMaterial, in: Circle())
                                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                
                                // Compact Journal Mode Indicator
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 6, height: 6)
                                    
                                    Text(currentJournalMode.displayName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                            }
                            .padding(.bottom, 24)
                            .background(headerGradient)
                            
                            // Main Content
                            VStack(spacing: 20) {
                                if currentJournalMode == .guidedPrompts {
                                    // Morning Section
                                    JournalSectionCard(
                                        title: "Morning",
                                        icon: "sunrise.fill",
                                        iconColor: .orange,
                                        prompt: viewModel.morningPrompt,
                                        text: $viewModel.morningText,
                                        geometry: geometry
                                    )
                                    
                                    // Evening Section  
                                    JournalSectionCard(
                                        title: "Evening",
                                        icon: "moon.fill",
                                        iconColor: .purple,
                                        prompt: viewModel.eveningPrompt,
                                        text: $viewModel.eveningText,
                                        geometry: geometry
                                    )
                                } else {
                                    // Free Writing Section
                                    JournalSectionCard(
                                        title: "Free Writing",
                                        icon: "pencil.circle.fill",
                                        iconColor: .blue,
                                        prompt: "Write freely about your day, thoughts, feelings, or anything that comes to mind.",
                                        text: $viewModel.freeWriteText,
                                        geometry: geometry,
                                        isLarger: true
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100) // Space for save button
                        }
                    }
                    
                    // Floating Save Button
                    VStack {
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isAnimating = true
                                viewModel.saveEntry()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if isAnimating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                }
                                
                                Text(isAnimating ? "Saving..." : "Save Entry")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: Capsule()
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                        }
                        .disabled(isAnimating)
                        .scaleEffect(isAnimating ? 0.95 : 1.0)
                        .padding(.bottom, 34)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $selectedDate) {
                    viewModel.loadEntryFor(date: selectedDate)
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.loadEntryFor(date: selectedDate)
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

// Premium Journal Section Card
struct JournalSectionCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let prompt: String
    @Binding var text: String
    let geometry: GeometryProxy
    var isLarger: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isTextEditorFocused: Bool
    
    var cardGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.12, green: 0.12, blue: 0.16)]
                : [Color.white, Color(red: 0.99, green: 0.99, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Reflection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Compact Prompt
            if !prompt.isEmpty {
                Text(prompt)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            
            // Premium Text Editor
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isTextEditorFocused 
                                        ? LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                                    lineWidth: isTextEditorFocused ? 2 : 1
                                )
                        )
                        .shadow(
                            color: isTextEditorFocused ? .blue.opacity(0.2) : .black.opacity(0.05),
                            radius: isTextEditorFocused ? 8 : 4,
                            x: 0,
                            y: isTextEditorFocused ? 4 : 2
                        )
                        .frame(height: isLarger ? 280 : 180)
                    
                    TextEditor(text: $text)
                        .focused($isTextEditorFocused)
                        .font(.body)
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                        .padding(16)
                        .frame(height: isLarger ? 280 : 180)
                    
                    // Placeholder
                    if text.isEmpty {
                        Text("Start writing...")
                            .font(.body)
                            .foregroundColor(.tertiary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 24)
                            .allowsHitTesting(false)
                    }
                }
                
                // Character count
                HStack {
                    Spacer()
                    Text("\(text.count) characters")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTextEditorFocused)
    }
}

// Elegant Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let onDateChanged: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Select Date")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                DatePicker(
                    "Journal Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                
                Spacer()
            }
            .background(
                LinearGradient(
                    colors: colorScheme == .dark 
                        ? [Color(red: 0.02, green: 0.02, blue: 0.05), Color(red: 0.05, green: 0.05, blue: 0.08)]
                        : [Color(red: 0.96, green: 0.96, blue: 0.98), Color(red: 0.98, green: 0.98, blue: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDateChanged()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
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
    private var currentDate = Date()
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func loadEntryFor(date: Date) {
        guard let modelContext = modelContext else { return }
        
        currentDate = Calendar.current.startOfDay(for: date)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        let prompts = PromptManager.shared.getPromptsForDate(currentDate)
        
        morningPrompt = prompts.morning
        eveningPrompt = prompts.evening
        
        let predicate = #Predicate<JournalEntry> { entry in
            entry.date >= currentDate && entry.date < nextDay
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
                // Create new entry for selected date
                let newEntry = JournalEntry(
                    date: currentDate,
                    morningPrompt: prompts.morning,
                    eveningPrompt: prompts.evening
                )
                modelContext.insert(newEntry)
                currentEntry = newEntry
                morningText = ""
                eveningText = ""
                freeWriteText = ""
                try modelContext.save()
            }
        } catch {
            print("Error loading journal entry: \(error)")
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