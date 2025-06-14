import SwiftUI

struct LogWaterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var waterAmount = ""
    @State private var selectedQuickAmount: Double?
    
    private let quickAmounts = [8.0, 12.0, 16.0, 20.0, 24.0, 32.0]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Log Water")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Quick water intake entry")
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
                            QuickAmountButton(
                                amount: amount,
                                isSelected: selectedQuickAmount == amount
                            ) {
                                selectedQuickAmount = amount
                                waterAmount = "\(Int(amount))"
                            }
                        }
                    }
                }
                
                // Custom Amount Entry
                VStack(spacing: 12) {
                    Text("Custom Amount")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        TextField("Enter ounces", text: $waterAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        Text("oz")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Log Water") {
                        // TODO: Implement water logging
                        dismiss()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(waterAmount.isEmpty)
                    
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
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct QuickAmountButton: View {
    let amount: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Int(amount))")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("oz")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.cyan.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LogWaterView()
}