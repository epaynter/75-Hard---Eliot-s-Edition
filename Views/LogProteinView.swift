import SwiftUI

struct LogProteinView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var proteinAmount = ""
    @State private var selectedQuickAmount: Double?
    @State private var selectedSource = ""
    
    private let quickAmounts = [20.0, 25.0, 30.0, 40.0, 50.0, 60.0]
    private let commonSources = ["Chicken", "Protein Shake", "Fish", "Beef", "Eggs", "Greek Yogurt"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Log Protein")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Track your protein intake")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Quick Amount Buttons
                VStack(spacing: 16) {
                    Text("Quick Add")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(quickAmounts, id: \.self) { amount in
                            QuickProteinButton(
                                amount: amount,
                                isSelected: selectedQuickAmount == amount
                            ) {
                                selectedQuickAmount = amount
                                proteinAmount = "\(Int(amount))"
                            }
                        }
                    }
                }
                
                // Protein Source Selection
                VStack(spacing: 12) {
                    Text("Protein Source (Optional)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonSources, id: \.self) { source in
                                Button(source) {
                                    selectedSource = selectedSource == source ? "" : source
                                }
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedSource == source ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedSource == source ? Color.green : Color(.systemGray5))
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Custom Amount Entry
                VStack(spacing: 12) {
                    Text("Custom Amount")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        TextField("Enter grams", text: $proteinAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        Text("g")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Log Protein") {
                        // TODO: Implement protein logging
                        dismiss()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(proteinAmount.isEmpty)
                    
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

struct QuickProteinButton: View {
    let amount: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Int(amount))")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.green.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LogProteinView()
}