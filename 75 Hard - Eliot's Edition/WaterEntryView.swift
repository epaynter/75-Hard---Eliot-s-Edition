//
//  WaterEntryView.swift
//  75 Hard - Eliot's Edition - WARRIOR EDITION
//
//  Transformed into Premium Hydration Command Center
//

import SwiftUI
import SwiftData

struct WaterEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    @State private var animatingProgress = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // WARRIOR BACKGROUND
                DesignSystem.Colors.heroGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // HYDRATION COMMAND HEADER
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.cyan.opacity(0.5), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: DesignSystem.Spacing.sm) {
                                Text("HYDRATION PROTOCOL")
                                    .font(DesignSystem.Typography.title1)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .fontWeight(.bold)
                                    .tracking(2)
                                
                                Text("MAINTAIN TACTICAL READINESS")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.top, DesignSystem.Spacing.lg)
                        
                        // MISSION STATUS
                        HydrationStatusCommand(viewModel: viewModel, animatingProgress: $animatingProgress)
                        
                        // QUICK DEPLOYMENT ACTIONS
                        QuickHydrationActions(viewModel: viewModel)
                        
                        // MANUAL ENTRY SYSTEM
                        ManualHydrationEntry(viewModel: viewModel)
                        
                        // INTELLIGENCE SUMMARY
                        HydrationIntelligence(viewModel: viewModel)
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
                    Button("COMPLETE") {
                        HapticManager.shared.success()
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.accent)
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3)) {
                    animatingProgress = true
                }
            }
        }
    }
}

// MARK: - HYDRATION STATUS COMMAND
struct HydrationStatusCommand: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @Binding var animatingProgress: Bool
    
    var body: some View {
        WarriorCard {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Status Header
                HStack {
                    Text("MISSION STATUS")
                        .font(DesignSystem.Typography.motivational)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .tracking(2)
                    
                    Spacer()
                    
                    Text(viewModel.hydrationStatus)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(viewModel.waterProgressPercentage >= 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.accent)
                        .fontWeight(.bold)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill((viewModel.waterProgressPercentage >= 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.accent).opacity(0.1))
                        )
                }
                
                // Progress Display
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("\(Int(viewModel.totalWaterOunces))")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.cyan.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text("OUNCES CONSUMED")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .fontWeight(.bold)
                        .tracking(1)
                }
                
                // Progress Bar
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Text("TARGET: \(Int(viewModel.goalWaterOunces)) OZ")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.waterProgressPercentage * 100))%")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.accent)
                            .fontWeight(.bold)
                    }
                    
                    HydrationProgressBar(
                        progress: animatingProgress ? viewModel.waterProgressPercentage : 0,
                        height: 16
                    )
                }
                
                // Completion Message
                if viewModel.waterProgressPercentage >= 1.0 {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.success)
                        
                        Text("HYDRATION PROTOCOL COMPLETE")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.success)
                            .fontWeight(.bold)
                            .tracking(1)
                    }
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(DesignSystem.Colors.success.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .stroke(DesignSystem.Colors.success.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - HYDRATION PROGRESS BAR
struct HydrationProgressBar: View {
    let progress: Double
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(DesignSystem.Colors.backgroundTertiary)
                .frame(height: height)
            
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(0, progress * UIScreen.main.bounds.width * 0.75), height: height)
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
                .overlay(
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, progress * UIScreen.main.bounds.width * 0.75), height: height)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: progress)
                )
        }
    }
}

// MARK: - QUICK HYDRATION ACTIONS
struct QuickHydrationActions: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("QUICK DEPLOYMENT")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                    WarriorQuickWaterButton(amount: 8, action: {
                        HapticManager.shared.impact(.heavy)
                        viewModel.addWater(ounces: 8)
                    })
                    
                    WarriorQuickWaterButton(amount: 16, action: {
                        HapticManager.shared.impact(.heavy)
                        viewModel.addWater(ounces: 16)
                    })
                    
                    WarriorQuickWaterButton(amount: 24, action: {
                        HapticManager.shared.impact(.heavy)
                        viewModel.addWater(ounces: 24)
                    })
                    
                    WarriorQuickWaterButton(amount: 32, action: {
                        HapticManager.shared.impact(.heavy)
                        viewModel.addWater(ounces: 32)
                    })
                }
            }
        }
    }
}

// MARK: - WARRIOR QUICK WATER BUTTON
struct WarriorQuickWaterButton: View {
    let amount: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("+\(Int(amount))")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("OZ")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .fontWeight(.bold)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.cyan.opacity(0.4), radius: 6, x: 0, y: 4)
            )
        }
        .buttonStyle(PowerButtonStyle())
    }
}

// MARK: - MANUAL HYDRATION ENTRY
struct ManualHydrationEntry: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @State private var manualAmount: String = ""
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("MANUAL ENTRY SYSTEM")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Custom Amount Input
                    HStack(spacing: DesignSystem.Spacing.md) {
                        TextField("Amount", text: $manualAmount)
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .fontWeight(.bold)
                            .keyboardType(.numberPad)
                            .textFieldStyle(WarriorTextFieldStyle())
                        
                        Text("OZ")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .fontWeight(.bold)
                    }
                    
                    // Action Buttons
                    HStack(spacing: DesignSystem.Spacing.md) {
                        SecondaryButton("ADD INTAKE", icon: "plus.circle.fill") {
                            if let amount = Double(manualAmount), amount > 0 {
                                HapticManager.shared.impact(.heavy)
                                viewModel.addWater(ounces: amount)
                                manualAmount = ""
                            }
                        }
                        
                        SecondaryButton("REMOVE", icon: "minus.circle.fill") {
                            if let amount = Double(manualAmount), amount > 0 {
                                HapticManager.shared.impact(.medium)
                                viewModel.subtractWater(ounces: amount)
                                manualAmount = ""
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - WARRIOR TEXT FIELD STYLE
struct WarriorTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(DesignSystem.Colors.backgroundTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(DesignSystem.Colors.accent.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

// MARK: - HYDRATION INTELLIGENCE
struct HydrationIntelligence: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("TACTICAL INTELLIGENCE")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    IntelligenceRow(
                        title: "CURRENT INTAKE",
                        value: "\(Int(viewModel.totalWaterOunces)) oz",
                        icon: "drop.fill",
                        color: .cyan
                    )
                    
                    IntelligenceRow(
                        title: "REMAINING TARGET",
                        value: "\(max(0, Int(viewModel.goalWaterOunces - viewModel.totalWaterOunces))) oz",
                        icon: "target",
                        color: DesignSystem.Colors.accent
                    )
                    
                    IntelligenceRow(
                        title: "COMPLETION RATE",
                        value: "\(Int(viewModel.waterProgressPercentage * 100))%",
                        icon: "percent",
                        color: viewModel.waterProgressPercentage >= 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.primary
                    )
                    
                    IntelligenceRow(
                        title: "HYDRATION STATUS",
                        value: viewModel.hydrationStatus,
                        icon: "checkmark.shield.fill",
                        color: viewModel.waterProgressPercentage >= 1.0 ? DesignSystem.Colors.success : DesignSystem.Colors.warning
                    )
                }
                
                // Reset Option
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Divider()
                        .background(DesignSystem.Colors.backgroundTertiary)
                    
                    PrimaryButton("RESET PROTOCOL", icon: "arrow.counterclockwise", isDestructive: true) {
                        HapticManager.shared.warning()
                        viewModel.resetWater()
                    }
                }
            }
        }
    }
}

// MARK: - INTELLIGENCE ROW
struct IntelligenceRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
    }
}

#Preview {
    WaterEntryView(viewModel: ChecklistViewModel())
}