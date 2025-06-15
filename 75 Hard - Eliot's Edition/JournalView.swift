//
//  JournalView.swift
//  75 Hard - Eliot's Edition - WARRIOR EDITION
//
//  Transformed into Premium Mission Log Interface
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
            ZStack {
                // WARRIOR BACKGROUND
                DesignSystem.Colors.heroGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // MISSION LOG HEADER
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(DesignSystem.Colors.goldGradient)
                                .shadow(color: DesignSystem.Colors.accent.opacity(0.5), radius: 6, x: 0, y: 3)
                            
                            Text("MISSION LOG")
                                .font(DesignSystem.Typography.title1)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .fontWeight(.bold)
                                .tracking(2)
                            
                            Text(Date(), style: .date)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .fontWeight(.semibold)
                            
                            // Mode Indicator
                            Text(currentJournalMode.displayName.uppercased())
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.accent)
                                .fontWeight(.bold)
                                .tracking(1)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                        .fill(DesignSystem.Colors.accent.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                                .stroke(DesignSystem.Colors.accent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.top, DesignSystem.Spacing.lg)
                        
                        if currentJournalMode == .guidedPrompts {
                            // MORNING OPERATIONS DEBRIEF
                            MorningMissionSection(viewModel: viewModel)
                            
                            // EVENING TACTICAL REVIEW
                            EveningMissionSection(viewModel: viewModel)
                        } else {
                            // FREE INTELLIGENCE REPORT
                            FreeIntelSection(viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .preferredColorScheme(.dark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ABORT") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DEPLOY") {
                        HapticManager.shared.success()
                        viewModel.saveEntry()
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.accent)
                    .fontWeight(.bold)
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

// MARK: - MORNING MISSION SECTION
struct MorningMissionSection: View {
    @ObservedObject var viewModel: JournalViewModel
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Section Header
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.goldGradient)
                            .frame(width: 50, height: 50)
                            .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "sunrise.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("MORNING OPERATIONS")
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .fontWeight(.bold)
                        
                        Text("Strategic Planning Phase")
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                // Mission Briefing
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("MISSION BRIEFING")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .fontWeight(.bold)
                        .tracking(1)
                    
                    Text(viewModel.morningPrompt)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(DesignSystem.Colors.backgroundTertiary)
                        )
                }
                
                // Intelligence Input
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("INTELLIGENCE REPORT")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .fontWeight(.bold)
                        .tracking(1)
                    
                    WarriorTextEditor(text: $viewModel.morningText, placeholder: "Document your strategic mindset, goals, and battle plan for the day ahead...", minHeight: 120)
                }
            }
        }
    }
}

// MARK: - EVENING MISSION SECTION
struct EveningMissionSection: View {
    @ObservedObject var viewModel: JournalViewModel
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Section Header
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.purple.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "moon.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("EVENING DEBRIEF")
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .fontWeight(.bold)
                        
                        Text("Tactical Analysis Phase")
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                // Mission Analysis
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("MISSION ANALYSIS")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .fontWeight(.bold)
                        .tracking(1)
                    
                    Text(viewModel.eveningPrompt)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(DesignSystem.Colors.backgroundTertiary)
                        )
                }
                
                // After Action Report
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("AFTER ACTION REPORT")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .fontWeight(.bold)
                        .tracking(1)
                    
                    WarriorTextEditor(text: $viewModel.eveningText, placeholder: "Assess your performance, victories achieved, lessons learned, and tactical adjustments for tomorrow...", minHeight: 120)
                }
            }
        }
    }
}

// MARK: - FREE INTEL SECTION
struct FreeIntelSection: View {
    @ObservedObject var viewModel: JournalViewModel
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Section Header
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.primaryGradient)
                            .frame(width: 50, height: 50)
                            .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("FREE INTELLIGENCE")
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .fontWeight(.bold)
                        
                        Text("Unstructured Tactical Notes")
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                // Mission Brief
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("OPEN CHANNEL COMMUNICATION")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .fontWeight(.bold)
                        .tracking(1)
                    
                    Text("Document your thoughts, strategic insights, battlefield observations, mental state, and any intelligence that supports your transformation mission.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(DesignSystem.Colors.backgroundTertiary)
                        )
                }
                
                // Free Text Input
                WarriorTextEditor(text: $viewModel.freeWriteText, placeholder: "Begin your intelligence report...", minHeight: 200)
            }
        }
    }
}

// MARK: - WARRIOR TEXT EDITOR
struct WarriorTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    
    init(text: Binding<String>, placeholder: String, minHeight: CGFloat = 120) {
        self._text = text
        self.placeholder = placeholder
        self.minHeight = minHeight
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.backgroundTertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .stroke(
                            text.isEmpty ? DesignSystem.Colors.backgroundTertiary : DesignSystem.Colors.accent.opacity(0.3),
                            lineWidth: 1
                        )
                )
            
            // Text Editor
            TextEditor(text: $text)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .padding(DesignSystem.Spacing.md)
                .background(Color.clear)
                .scrollContentBackground(.hidden) // iOS 16+
            
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .padding(.horizontal, DesignSystem.Spacing.md + 4)
                    .padding(.vertical, DesignSystem.Spacing.md + 8)
                    .allowsHitTesting(false)
            }
        }
        .frame(minHeight: minHeight)
        .onTapGesture {
            // Focus text editor on tap
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