import SwiftUI

struct QuickJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var journalText = ""
    @State private var selectedPrompt: JournalPrompt?
    @State private var entryType: EntryType = .freeform
    
    enum EntryType: String, CaseIterable {
        case freeform = "Free Write"
        case gratitude = "Gratitude"
        case reflection = "Reflection"
        case goals = "Goals"
        
        var prompt: String {
            switch self {
            case .freeform: return "What's on your mind today?"
            case .gratitude: return "What are you grateful for today?"
            case .reflection: return "How did today go? What did you learn?"
            case .goals: return "What are your goals for tomorrow?"
            }
        }
        
        var icon: String {
            switch self {
            case .freeform: return "pencil"
            case .gratitude: return "heart.fill"
            case .reflection: return "lightbulb.fill"
            case .goals: return "target"
            }
        }
        
        var color: Color {
            switch self {
            case .freeform: return .blue
            case .gratitude: return .pink
            case .reflection: return .orange
            case .goals: return .green
            }
        }
    }
    
    enum JournalPrompt: String, CaseIterable {
        case wins = "What were your biggest wins today?"
        case challenges = "What challenges did you overcome?"
        case mindset = "How is your mindset evolving?"
        case energy = "What gave you energy today?"
        case learned = "What did you learn about yourself?"
        case proud = "What are you most proud of?"
        
        var category: String {
            switch self {
            case .wins, .proud: return "Achievement"
            case .challenges, .mindset: return "Growth"
            case .energy, .learned: return "Self-Awareness"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Quick Journal")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Capture your thoughts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Entry Type Selection
                VStack(spacing: 12) {
                    Text("Entry Type")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(EntryType.allCases, id: \.self) { type in
                                EntryTypeButton(
                                    type: type,
                                    isSelected: entryType == type
                                ) {
                                    entryType = type
                                    // Clear existing text when changing type
                                    if journalText == type.prompt {
                                        journalText = ""
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Quick Prompts (optional)
                if entryType == .reflection {
                    VStack(spacing: 12) {
                        Text("Quick Prompts")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(JournalPrompt.allCases, id: \.self) { prompt in
                                    Button(prompt.rawValue) {
                                        selectedPrompt = prompt
                                        journalText = prompt.rawValue + "\n\n"
                                    }
                                    .font(.caption)
                                    .foregroundColor(selectedPrompt == prompt ? .white : .secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedPrompt == prompt ? Color.purple : Color(.systemGray5))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Text Entry
                VStack(spacing: 8) {
                    HStack {
                        Text("Your Entry")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(journalText.count) characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $journalText)
                            .font(.body)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .frame(minHeight: 120)
                        
                        if journalText.isEmpty {
                            Text(entryType.prompt)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Save Entry") {
                        // TODO: Implement journal entry saving
                        dismiss()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct EntryTypeButton: View {
    let type: QuickJournalEntryView.EntryType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? type.color : .secondary)
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? type.color : .secondary)
            }
            .frame(width: 70, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? type.color.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuickJournalEntryView()
}