//
//  HomeView.swift
//  75 Hard - Eliot's Edition - WARRIOR EDITION
//
//  Transformed into Premium Transformation Command Center
//

import SwiftUI
import SwiftData
import PhotosUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = ChecklistViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingJournal = false
    @State private var showingCalendar = false
    @State private var showingCamera = false
    @State private var showingSettings = false
    @State private var showingPhotoDetail = false
    @State private var showingDayNavigation = false
    @State private var showingWaterEntry = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // WARRIOR BACKGROUND - Dark & Intense
                DesignSystem.Colors.heroGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // WARRIOR HEADER - Command Center Style
                        WarriorHeader(viewModel: viewModel) {
                            showingDayNavigation = true
                        }
                        
                        // BATTLE PROGRESS - Mission Status
                        BattleProgressCommand(viewModel: viewModel)
                        
                        // MISSION CHECKLIST - Daily Operations
                        MissionChecklistCommand(
                            viewModel: viewModel,
                            showingWaterEntry: $showingWaterEntry,
                            showingPhotoDetail: $showingPhotoDetail
                        )
                        
                        // TACTICAL ACTIONS - Quick Deploy
                        TacticalActionsCommand(
                            showingCamera: $showingCamera,
                            showingJournal: $showingJournal,
                            showingCalendar: $showingCalendar
                        )
                        
                        // WARRIOR MINDSET - Daily Fuel
                        WarriorMindsetCard()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .preferredColorScheme(.dark) // Force dark mode for warrior aesthetic
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.medium)
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.accent)
                    }
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.loadTodaysData()
            }
            .sheet(isPresented: $showingJournal) {
                JournalView()
            }
            .sheet(isPresented: $showingCalendar) {
                CalendarView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingCamera) {
                WarriorPhotoCapture(viewModel: viewModel) {
                    showingPhotoDetail = true
                }
            }
            .sheet(isPresented: $showingPhotoDetail) {
                PhotoDetailView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingWaterEntry) {
                WaterEntryView(viewModel: viewModel)
            }
            .alert("TACTICAL NAVIGATION", isPresented: $showingDayNavigation) {
                Button("← PREVIOUS DAY") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.navigateToPreviousDay()
                    }
                }
                .disabled(!viewModel.canNavigateToPreviousDay())
                
                Button("NEXT DAY →") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.navigateToNextDay()
                    }
                }
                .disabled(!viewModel.canNavigateToNextDay())
                
                Button("⚡ TODAY") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.navigateToToday()
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select your battleground. Navigate to dominate another day or return to today's mission.")
            }
        }
    }
}

// MARK: - WARRIOR HEADER - Command Center
struct WarriorHeader: View {
    @ObservedObject var viewModel: ChecklistViewModel
    let onDayNavigation: () -> Void
    
    var body: some View {
        WarriorCard {
            VStack(spacing: DesignSystem.Spacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("DAY")
                            .font(DesignSystem.Typography.motivational)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .tracking(3)
                        
                        Text("\(viewModel.currentDay)")
                            .font(DesignSystem.Typography.heroTitle)
                            .foregroundStyle(DesignSystem.Colors.primaryGradient)
                            .shadow(color: DesignSystem.Colors.primary.opacity(0.5), radius: 4, x: 0, y: 2)
                        
                        Text("OF \(viewModel.totalDays)")
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    // Tactical Navigation
                    WarriorDayControls(viewModel: viewModel, onTap: onDayNavigation)
                }
                
                // Mission Status
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text(MotivationalMessages.getDailyMessage())
                        .font(DesignSystem.Typography.motivational)
                        .foregroundColor(DesignSystem.Colors.accent)
                        .tracking(2)
                        .multilineTextAlignment(.center)
                        .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    if !Calendar.current.isDateInToday(viewModel.selectedDate) {
                        Text(viewModel.selectedDate, style: .date)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .fill(DesignSystem.Colors.backgroundTertiary)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - WARRIOR DAY CONTROLS
struct WarriorDayControls: View {
    @ObservedObject var viewModel: ChecklistViewModel
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Button(action: {
                    HapticManager.shared.impact(.heavy)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.navigateToPreviousDay()
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .foregroundStyle(viewModel.canNavigateToPreviousDay() ? DesignSystem.Colors.primaryGradient : DesignSystem.Colors.backgroundTertiary)
                }
                .disabled(!viewModel.canNavigateToPreviousDay())
                
                Button(action: {
                    HapticManager.shared.impact(.light)
                    onTap()
                }) {
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.title3)
                        Text("JUMP")
                            .font(DesignSystem.Typography.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(DesignSystem.Colors.accent)
                }
                
                Button(action: {
                    HapticManager.shared.impact(.heavy)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.navigateToNextDay()
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundStyle(viewModel.canNavigateToNextDay() ? DesignSystem.Colors.primaryGradient : DesignSystem.Colors.backgroundTertiary)
                }
                .disabled(!viewModel.canNavigateToNextDay())
            }
        }
    }
}

// MARK: - BATTLE PROGRESS - Mission Status
struct BattleProgressCommand: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        WarriorCard {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Today's Battle Status
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack {
                        Text("MISSION STATUS")
                            .font(DesignSystem.Typography.motivational)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .tracking(2)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.todaysProgress * 100))%")
                            .font(DesignSystem.Typography.stats)
                            .foregroundStyle(DesignSystem.Colors.goldGradient)
                            .shadow(color: DesignSystem.Colors.accent.opacity(0.5), radius: 3, x: 0, y: 2)
                    }
                    
                    WarriorProgressBar(progress: viewModel.todaysProgress, height: 16, showPercentage: false)
                    
                    Text(MotivationalMessages.getProgressMessage(for: viewModel.todaysProgress))
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .fontWeight(.semibold)
                        .tracking(1)
                }
                
                // Campaign Progress
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Text("CAMPAIGN PROGRESS")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .tracking(1)
                        
                        Spacer()
                        
                        Text("\(viewModel.daysCompleted)/\(viewModel.totalDays) DAYS")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .fontWeight(.bold)
                    }
                    
                    ProgressView(value: viewModel.overallProgress)
                        .progressViewStyle(WarriorProgressViewStyle())
                        .scaleEffect(x: 1, y: 2)
                }
            }
        }
    }
}

// MARK: - WARRIOR PROGRESS VIEW STYLE
struct WarriorProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(DesignSystem.Colors.backgroundTertiary)
                .frame(height: 8)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(DesignSystem.Colors.goldGradient)
                .frame(width: (configuration.fractionCompleted ?? 0) * 200, height: 8)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: configuration.fractionCompleted)
        }
    }
}

// MARK: - MISSION CHECKLIST - Daily Operations
struct MissionChecklistCommand: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @Binding var showingWaterEntry: Bool
    @Binding var showingPhotoDetail: Bool
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("DAILY OPERATIONS")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Reading Mission
                    WarriorMissionRow(
                        title: "INTEL BRIEFING",
                        subtitle: "10 pages minimum",
                        icon: "book.fill",
                        isCompleted: viewModel.hasRead,
                        color: DesignSystem.Colors.success
                    ) {
                        HapticManager.shared.impact(.heavy)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.toggleRead()
                        }
                    }
                    
                    // Workout Operations
                    WarriorWorkoutRow(viewModel: viewModel)
                    
                    // Hydration Protocol
                    WarriorHydrationRow(viewModel: viewModel, showingWaterEntry: $showingWaterEntry)
                    
                    // Sleep Recovery
                    WarriorMissionRow(
                        title: "RECOVERY PROTOCOL",
                        subtitle: "7+ hours minimum",
                        icon: "bed.double.fill",
                        isCompleted: viewModel.hasSleep,
                        color: Color.purple
                    ) {
                        HapticManager.shared.impact(.heavy)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.toggleSleep()
                        }
                    }
                    
                    // Supplement Arsenal
                    WarriorSupplementsRow(viewModel: viewModel)
                    
                    // Progress Documentation
                    WarriorMissionRow(
                        title: "TRANSFORMATION INTEL",
                        subtitle: "Document progress",
                        icon: "camera.fill",
                        isCompleted: viewModel.hasPhoto,
                        color: Color.blue,
                        showViewButton: viewModel.hasPhoto && viewModel.isPhotoLocked
                    ) {
                        HapticManager.shared.impact(.heavy)
                        if !viewModel.isPhotoLocked {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.togglePhoto()
                            }
                        }
                    } viewAction: {
                        showingPhotoDetail = true
                    }
                    
                    // Journal Operations
                    WarriorMissionRow(
                        title: "MISSION LOG",
                        subtitle: "Document learnings",
                        icon: "book.closed.fill",
                        isCompleted: viewModel.hasJournaled,
                        color: DesignSystem.Colors.accent
                    ) {
                        HapticManager.shared.impact(.heavy)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.toggleJournaled()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - WARRIOR MISSION ROW
struct WarriorMissionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isCompleted: Bool
    let color: Color
    let showViewButton: Bool
    let action: () -> Void
    let viewAction: (() -> Void)?
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        isCompleted: Bool,
        color: Color,
        showViewButton: Bool = false,
        action: @escaping () -> Void,
        viewAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isCompleted = isCompleted
        self.color = color
        self.showViewButton = showViewButton
        self.action = action
        self.viewAction = viewAction
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Button(action: action) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Mission Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                            .fontWeight(.bold)
                    }
                    
                    // Mission Details
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(title)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .fontWeight(.bold)
                        
                        Text(subtitle)
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Status Indicator
                    ZStack {
                        Circle()
                            .stroke(
                                isCompleted ? color : DesignSystem.Colors.backgroundTertiary,
                                lineWidth: 3
                            )
                            .frame(width: 32, height: 32)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(color)
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isCompleted)
                }
            }
            .buttonStyle(MissionButtonStyle())
            
            // View Button if needed
            if showViewButton, let viewAction = viewAction {
                HStack {
                    Spacer()
                    Button("VIEW INTEL") {
                        HapticManager.shared.impact(.light)
                        viewAction()
                    }
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(color)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(color.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .stroke(color.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.leading, 66) // Align with mission text
            }
        }
    }
}

// MARK: - MISSION BUTTON STYLE
struct MissionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - WARRIOR WORKOUT ROW
struct WarriorWorkoutRow: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Workout Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.danger.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "figure.run")
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.danger)
                    .fontWeight(.bold)
            }
            
            // Workout Details
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("COMBAT TRAINING")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                
                Text("2 sessions required")
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Workout Counter
            HStack(spacing: DesignSystem.Spacing.md) {
                Button("-") {
                    HapticManager.shared.impact(.heavy)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.decrementWorkouts()
                    }
                }
                .disabled(viewModel.workoutsCompleted <= 0)
                .buttonStyle(WarriorCounterButtonStyle(
                    isEnabled: viewModel.workoutsCompleted > 0,
                    color: DesignSystem.Colors.danger
                ))
                
                Text("\(viewModel.workoutsCompleted)/2")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.black)
                    .frame(minWidth: 40)
                
                Button("+") {
                    HapticManager.shared.impact(.heavy)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.incrementWorkouts()
                    }
                }
                .disabled(viewModel.workoutsCompleted >= 2)
                .buttonStyle(WarriorCounterButtonStyle(
                    isEnabled: viewModel.workoutsCompleted < 2,
                    color: DesignSystem.Colors.danger
                ))
            }
        }
    }
}

// MARK: - WARRIOR COUNTER BUTTON STYLE
struct WarriorCounterButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.title3)
            .fontWeight(.black)
            .foregroundColor(isEnabled ? .white : DesignSystem.Colors.textTertiary)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(isEnabled ? color : DesignSystem.Colors.backgroundTertiary)
                    .shadow(
                        color: isEnabled ? color.opacity(0.3) : .clear,
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - WARRIOR HYDRATION ROW
struct WarriorHydrationRow: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @Binding var showingWaterEntry: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Hydration Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(.cyan)
                        .fontWeight(.bold)
                }
                
                // Hydration Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("HYDRATION PROTOCOL")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .fontWeight(.bold)
                    
                    Text(viewModel.waterGoalText)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button("DEPLOY") {
                    HapticManager.shared.impact(.medium)
                    showingWaterEntry = true
                }
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.cyan)
                .fontWeight(.bold)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(Color.cyan.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Hydration Progress
            WarriorProgressBar(
                progress: viewModel.waterProgressPercentage,
                height: 10,
                showPercentage: false
            )
        }
    }
}

// MARK: - WARRIOR SUPPLEMENTS ROW
struct WarriorSupplementsRow: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Supplements Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.success.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "pills.fill")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.success)
                        .fontWeight(.bold)
                }
                
                // Supplements Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("SUPPLEMENT ARSENAL")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .fontWeight(.bold)
                    
                    Text("\(viewModel.supplementsTaken.count)/\(viewModel.todaySupplements.count) completed")
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Completion Ring
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.backgroundTertiary, lineWidth: 3)
                        .frame(width: 32, height: 32)
                    
                    Circle()
                        .trim(from: 0.0, to: viewModel.supplementsProgress)
                        .stroke(DesignSystem.Colors.success, lineWidth: 3)
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: viewModel.supplementsProgress)
                    
                    if viewModel.hasAllSupplementsTaken {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(DesignSystem.Colors.success)
                    }
                }
            }
            
            // Supplement Pills
            if !viewModel.todaySupplements.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.todaySupplements, id: \.id) { supplement in
                        WarriorSupplementPill(
                            supplement: supplement,
                            isCompleted: viewModel.isSupplementTaken(supplement)
                        ) {
                            HapticManager.shared.impact(.medium)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.toggleSupplement(supplement)
                            }
                        }
                    }
                }
            } else {
                Text("NO SUPPLEMENTS CONFIGURED")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .fontWeight(.medium)
                    .tracking(1)
            }
        }
    }
}

// MARK: - WARRIOR SUPPLEMENT PILL
struct WarriorSupplementPill: View {
    let supplement: Supplement
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(supplement.name)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(supplement.dosage)
                        .font(.system(size: 10))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(
                        isCompleted
                        ? DesignSystem.Colors.success.opacity(0.1)
                        : DesignSystem.Colors.backgroundTertiary
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(
                                isCompleted
                                ? DesignSystem.Colors.success.opacity(0.3)
                                : .clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - TACTICAL ACTIONS - Quick Deploy
struct TacticalActionsCommand: View {
    @Binding var showingCamera: Bool
    @Binding var showingJournal: Bool
    @Binding var showingCalendar: Bool
    
    var body: some View {
        WarriorCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text("TACTICAL ACTIONS")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    WarriorTacticalButton(
                        title: "PHOTO INTEL",
                        icon: "camera.fill",
                        gradient: LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        HapticManager.shared.impact(.heavy)
                        showingCamera = true
                    }
                    
                    WarriorTacticalButton(
                        title: "MISSION LOG",
                        icon: "book.closed.fill",
                        gradient: DesignSystem.Colors.goldGradient
                    ) {
                        HapticManager.shared.impact(.heavy)
                        showingJournal = true
                    }
                    
                    WarriorTacticalButton(
                        title: "BATTLE MAP",
                        icon: "calendar",
                        gradient: DesignSystem.Colors.primaryGradient
                    ) {
                        HapticManager.shared.impact(.heavy)
                        showingCalendar = true
                    }
                }
            }
        }
    }
}

// MARK: - WARRIOR TACTICAL BUTTON
struct WarriorTacticalButton: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(gradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .buttonStyle(PowerButtonStyle())
    }
}

// MARK: - WARRIOR MINDSET CARD
struct WarriorMindsetCard: View {
    private let quotes = [
        "STAY HARD. - David Goggins",
        "DISCIPLINE EQUALS FREEDOM. - Jocko Willink",
        "GOOD. - Jocko Willink",
        "EXTREME OWNERSHIP. - Jocko Willink",
        "THE PATH TO SUCCESS IS MASSIVE, DETERMINED ACTION. - Tony Robbins",
        "YOU ARE IN DANGER OF LIVING A LIFE SO COMFORTABLE THAT YOU WILL DIE WITHOUT REALIZING YOUR TRUE POTENTIAL. - David Goggins",
        "PROGRESS EQUALS HAPPINESS. - Tony Robbins",
        "IF YOU WANT TO BE UNCOMMON AMONGST UNCOMMON PEOPLE, YOU HAVE TO DO WHAT THEY WON'T DO. - David Goggins",
        "THE CAVE YOU FEAR TO ENTER HOLDS THE TREASURE YOU SEEK. - Joseph Campbell",
        "WHAT WE DO NOW ECHOES IN ETERNITY. - Marcus Aurelius",
        "THE IMPEDIMENT TO ACTION ADVANCES ACTION. WHAT STANDS IN THE WAY BECOMES THE WAY. - Marcus Aurelius"
    ]
    
    var body: some View {
        WarriorCard {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("WARRIOR MINDSET")
                        .font(DesignSystem.Typography.motivational)
                        .foregroundColor(DesignSystem.Colors.accent)
                        .tracking(3)
                    
                    Rectangle()
                        .fill(DesignSystem.Colors.accent)
                        .frame(width: 60, height: 2)
                }
                
                // Quote
                Text(quotes.randomElement() ?? quotes[0])
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
            }
        }
    }
}

// MARK: - WARRIOR PHOTO CAPTURE
struct WarriorPhotoCapture: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    let onPhotoTaken: () -> Void
    
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.heroGradient
                    .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(DesignSystem.Colors.primaryGradient)
                            .shadow(color: DesignSystem.Colors.primary.opacity(0.5), radius: 8, x: 0, y: 4)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("TRANSFORMATION INTEL")
                                .font(DesignSystem.Typography.title1)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .fontWeight(.bold)
                            
                            Text("DOCUMENT YOUR WARRIOR JOURNEY")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    if isLoading {
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            ProgressView()
                                .scaleEffect(2)
                                .tint(DesignSystem.Colors.accent)
                            
                            Text("PROCESSING INTEL...")
                                .font(DesignSystem.Typography.motivational)
                                .foregroundColor(DesignSystem.Colors.accent)
                                .tracking(2)
                        }
                    } else {
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            PrimaryButton("CAPTURE INTEL", icon: "camera") {
                                showingCamera = true
                            }
                            
                            SecondaryButton("SELECT FROM ARCHIVE", icon: "photo.on.rectangle") {
                                showingGallery = true
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.xl)
            }
            .preferredColorScheme(.dark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("ABORT") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { image in
                    isLoading = true
                    processImage(image)
                }
            }
            .photosPicker(isPresented: $showingGallery, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { newPhoto in
                if let newPhoto = newPhoto {
                    isLoading = true
                    processSelectedPhoto(newPhoto)
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        HapticManager.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.handlePhotoSelection()
            isLoading = false
            dismiss()
            onPhotoTaken()
        }
    }
    
    private func processSelectedPhoto(_ photo: PhotosPickerItem) {
        HapticManager.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.handlePhotoSelection()
            selectedPhoto = nil
            isLoading = false
            dismiss()
            onPhotoTaken()
        }
    }
}

// MARK: - Camera View (Unchanged)
struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear
        picker.showsCameraControls = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        if uiViewController.sourceType == .camera {
            uiViewController.cameraCaptureMode = .photo
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        let dismiss: DismissAction
        
        init(onImageCaptured: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImageCaptured = onImageCaptured
            self.dismiss = dismiss
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self, Supplement.self, ChallengeSettings.self, NotificationPreference.self], inMemory: true)
}