//
//  WaterEntryView.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI

struct WaterEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    @State private var tempWaterAmount: Double
    @State private var customAmount = ""
    @State private var showingCustomEntry = false
    
    init(viewModel: ChecklistViewModel) {
        self.viewModel = viewModel
        self._tempWaterAmount = State(initialValue: viewModel.waterOunces)
    }
    
    private let quickAmounts = [8.0, 12.0, 16.0, 20.0, 24.0, 32.0]
    
    var progressGradient: LinearGradient {
        LinearGradient(
            colors: [.cyan, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.cyan.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(progressGradient)
                            
                            Text("Water Intake")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Track your daily hydration goal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)
                        
                        // Current Amount Display
                        VStack(spacing: 12) {
                            Text("\(Int(tempWaterAmount)) oz")
                                .font(.system(size: 40, weight: .semibold, design: .monospaced))
                                .foregroundStyle(progressGradient)
                            
                            Text("of \(Int(viewModel.challengeSettings?.goalWaterOunces ?? 128)) oz goal")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // NEW: Show conversions
                            Text(viewModel.waterGoalWithConversions)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            // Progress Bar
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.cyan.opacity(0.2))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(progressGradient)
                                    .frame(
                                        width: max(0, min(tempWaterAmount / (viewModel.challengeSettings?.goalWaterOunces ?? 128), 1.0) * 300),
                                        height: 12
                                    )
                                    .animation(.spring(response: 0.6), value: tempWaterAmount)
                            }
                            .frame(maxWidth: 300)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        
                        // Quick Add Buttons
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Quick Add")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                ForEach(quickAmounts, id: \.self) { amount in
                                    QuickWaterButton(amount: amount) {
                                        withAnimation(.spring()) {
                                            tempWaterAmount = min(tempWaterAmount + amount, 200.0)
                                        }
                                    }
                                }
                            }
                            
                            // Custom Amount Button
                            Button("Custom Amount") {
                                showingCustomEntry = true
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.cyan)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan, lineWidth: 2)
                            )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        
                        // Reset/Remove Options
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                Button("Remove 8oz") {
                                    withAnimation(.spring()) {
                                        tempWaterAmount = max(tempWaterAmount - 8.0, 0.0)
                                    }
                                }
                                .buttonStyle(SecondaryWaterButtonStyle())
                                .disabled(tempWaterAmount < 8.0)
                                
                                Button("Reset to 0") {
                                    withAnimation(.spring()) {
                                        tempWaterAmount = 0.0
                                    }
                                }
                                .buttonStyle(DestructiveWaterButtonStyle())
                                .disabled(tempWaterAmount == 0.0)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
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
                        viewModel.setWater(tempWaterAmount)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.cyan)
                }
            }
            .alert("Custom Amount", isPresented: $showingCustomEntry) {
                TextField("Enter ounces", text: $customAmount)
                    .keyboardType(.decimalPad)
                
                Button("Add") {
                    if let amount = Double(customAmount), amount > 0 {
                        withAnimation(.spring()) {
                            tempWaterAmount = min(tempWaterAmount + amount, 200.0)
                        }
                    }
                    customAmount = ""
                }
                
                Button("Set Total") {
                    if let amount = Double(customAmount), amount >= 0 {
                        withAnimation(.spring()) {
                            tempWaterAmount = min(amount, 200.0)
                        }
                    }
                    customAmount = ""
                }
                
                Button("Cancel", role: .cancel) {
                    customAmount = ""
                }
            } message: {
                Text("Enter the amount in ounces to add or set as total.")
            }
        }
    }
}

struct QuickWaterButton: View {
    let amount: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text("+\(Int(amount))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("oz")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.3), radius: 5, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SecondaryWaterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(configuration.isPressed ? 0.2 : 0.1))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct DestructiveWaterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(configuration.isPressed ? 0.2 : 0.1))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    WaterEntryView(viewModel: ChecklistViewModel())
}