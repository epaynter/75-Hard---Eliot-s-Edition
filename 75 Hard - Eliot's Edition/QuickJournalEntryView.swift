import SwiftUI
import SwiftData

struct QuickJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var entryText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextEditor(text: $entryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .overlay(
                        Group {
                            if entryText.isEmpty {
                                Text("How's your day going?")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 20)
                                    .padding(.leading, 5)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            .padding()
            .navigationTitle("Quick Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Save journal entry
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    QuickJournalEntryView()
} 