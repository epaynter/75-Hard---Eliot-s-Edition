//
//  HomeView.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
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
    
    var heroGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color(red: 0.08, green: 0.08, blue: 0.09), Color(red: 0.12, green: 0.12, blue: 0.13)]
                : [Color(red: 0.98, green: 0.98, blue: 0.99), Color(red: 0.95, green: 0.95, blue: 0.96)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var progressGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark ? [Color.white, Color.gray] : [Color.black, Color.gray],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card - Matching Screenshot
                        HeaderCard(viewModel: viewModel) {
                            showingDayNavigation = true
                        }
                        
                        // Circular Progress Card - Matching Screenshot
                        CircularProgressCard(viewModel: viewModel)
                        
                        // Daily Checklist
                        ChecklistCard(viewModel: viewModel, showingWaterEntry: $showingWaterEntry, showingPhotoDetail: $showingPhotoDetail)
                        
                        // Motivational Quote Section
                        MotivationalCard(viewModel: viewModel)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Padding for custom tab bar
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
            .sheet(isPresented: $showingCamera) {
                CameraFirstPhotoView(viewModel: viewModel) {
                    showingPhotoDetail = true
                }
            }
            .sheet(isPresented: $showingPhotoDetail) {
                PhotoDetailView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingWaterEntry) {
                WaterEntryView(viewModel: viewModel)
            }
            .alert("Navigate to Another Day", isPresented: $showingDayNavigation) {
                Button("Previous Day") {
                    withAnimation(.spring()) {
                        viewModel.navigateToPreviousDay()
                    }
                }
                .disabled(!viewModel.canNavigateToPreviousDay())
                
                Button("Next Day") {
                    withAnimation(.spring()) {
                        viewModel.navigateToNextDay()
                    }
                }
                .disabled(!viewModel.canNavigateToNextDay())
                
                Button("Today") {
                    withAnimation(.spring()) {
                        viewModel.navigateToToday()
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Navigate to view or edit another day's progress.")
            }
        }
    }
    
    // FIXED: Properly defined motivational message function
    private func getMotivationalMessage() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        let messages = [
            "NO EXCUSES",
            "STAY HARD", 
            "DISCIPLINE = FREEDOM",
            "LOCK IN",
            "MENTAL TOUGHNESS",
            "WARRIOR MINDSET",
            "LEVEL UP",
            "CLIMB HIGHER",
            "EARN YOUR KEEP",
            "ALL IN",
            "NO WEAK LINKS",
            "STAY FOCUSED",
            "PROVE YOURSELF",
            "DOMINATE TODAY",
            "EMBRACE THE GRIND",
            "CHOOSE HARD",
            "RELENTLESS",
            "UNBREAKABLE"
        ]
        
        return messages[dayOfYear % messages.count]
    }
    
    // NEW: Start challenge immediately
    private func startChallengeToday() {
        guard let settings = viewModel.challengeSettings else { return }
        settings.startDate = Date()
        
        do {
            try modelContext.save()
            viewModel.loadChallengeSettings()
            viewModel.loadTodaysData()
        } catch {
            print("Error starting challenge today: \(error)")
        }
    }
}

struct DayNavigationControls: View {
    let viewModel: ChecklistViewModel
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.navigateToPreviousDay()
                }
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .disabled(!viewModel.canNavigateToPreviousDay())
            .opacity(viewModel.canNavigateToPreviousDay() ? 1.0 : 0.3)
            
            Button(action: onTap) {
                VStack(spacing: 2) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("Jump")
                        .font(.caption2)
                }
                .foregroundStyle(.blue)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.navigateToNextDay()
                }
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .disabled(!viewModel.canNavigateToNextDay())
            .opacity(viewModel.canNavigateToNextDay() ? 1.0 : 0.3)
        }
    }
}

// New HeaderCard matching the screenshot
struct HeaderCard: View {
    @ObservedObject var viewModel: ChecklistViewModel
    let onJumpTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Day counter
            HStack {
                Text("Day \(viewModel.currentDay) of 75")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Main title and navigation
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Let's lock")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    HStack(spacing: 4) {
                        Text("in today")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Plant emoji
                        Text("🌱")
                            .font(.title)
                    }
                }
                
                Spacer()
                
                // Navigation controls
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.navigateToPreviousDay()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.blue)
                            )
                    }
                    .disabled(!viewModel.canNavigateToPreviousDay())
                    .opacity(viewModel.canNavigateToPreviousDay() ? 1.0 : 0.3)
                    
                    Button(action: onJumpTap) {
                        VStack(spacing: 2) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("Jump")
                                .font(.caption2)
                        }
                        .foregroundStyle(.blue)
                        .frame(width: 44, height: 44)
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.navigateToNextDay()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.blue)
                            )
                    }
                    .disabled(!viewModel.canNavigateToNextDay())
                    .opacity(viewModel.canNavigateToNextDay() ? 1.0 : 0.3)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
}

// New CircularProgressCard matching the screenshot
struct CircularProgressCard: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    private var completedTasks: Int {
        var count = 0
        if viewModel.hasRead { count += 1 }
        if viewModel.workoutsCompleted >= 2 { count += 1 }
        if viewModel.waterOunces >= (viewModel.challengeSettings?.goalWaterOunces ?? 128.0) { count += 1 }
        if viewModel.hasSleep { count += 1 }
        if viewModel.hasAllSupplementsTaken { count += 1 }
        if viewModel.hasPhoto { count += 1 }
        if viewModel.hasJournaled { count += 1 }
        return count
    }
    
    private var totalTasks: Int { 7 }
    
    private var progressPercentage: Double {
        Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress text
            Text("You've completed \(completedTasks) of \(totalTasks) tasks")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Circular progress indicator
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progressPercentage)
                
                // Percentage text
                Text("\(Int(progressPercentage * 100))%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Motivational message
            Text("Every journey starts with a single step! 🚀")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ProgressOverviewCard: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Daily Progress
            VStack(spacing: 12) {
                HStack {
                    Text("Today's Progress")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(Int(viewModel.todaysProgress * 100))%")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, viewModel.todaysProgress * 300), height: 12)
                        .animation(.spring(response: 0.6), value: viewModel.todaysProgress)
                }
                .frame(maxWidth: 300)
            }
            
            // Overall Challenge Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Challenge Progress")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.daysCompleted)/\(viewModel.totalDays)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: viewModel.overallProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .scaleEffect(x: 1, y: 1.5)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ChecklistCard: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @Binding var showingWaterEntry: Bool
    @Binding var showingPhotoDetail: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily Habits")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                // Reading
                ModernChecklistRow(
                    title: "Read 10 pages",
                    icon: "book.fill",
                    isCompleted: viewModel.hasRead,
                    color: .green
                ) {
                    withAnimation(.spring()) {
                        viewModel.toggleRead()
                    }
                }
                
                // Workouts
                WorkoutRow(viewModel: viewModel)
                
                // Water (Enhanced)
                WaterTrackingRow(viewModel: viewModel, showingWaterEntry: $showingWaterEntry)
                
                // Sleep
                ModernChecklistRow(
                    title: "7+ hours sleep",
                    icon: "bed.double.fill",
                    isCompleted: viewModel.hasSleep,
                    color: .purple
                ) {
                    withAnimation(.spring()) {
                        viewModel.toggleSleep()
                    }
                }
                
                // Supplements
                SupplementsRow(viewModel: viewModel)
                
                // Photo
                ModernChecklistRow(
                    title: "Progress photo",
                    icon: "camera.fill",
                    isCompleted: viewModel.hasPhoto,
                    color: .blue
                ) {
                    withAnimation(.spring()) {
                        if !viewModel.isPhotoLocked {
                            viewModel.togglePhoto()
                        }
                    }
                }
                
                // NEW: Show view photo button if photo exists
                if viewModel.hasPhoto, viewModel.isPhotoLocked {
                    HStack {
                        Spacer()
                        Button("View Photo") {
                            showingPhotoDetail = true
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.leading, 60) // Align with habit text
                }
                
                // Journal
                ModernChecklistRow(
                    title: "Journal entry",
                    icon: "book.closed.fill",
                    isCompleted: viewModel.hasJournaled,
                    color: .orange
                ) {
                    withAnimation(.spring()) {
                        viewModel.toggleJournaled()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernChecklistRow: View {
    let title: String
    let icon: String
    let isCompleted: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Circle()
                            .fill(color)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.3), value: isCompleted)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WorkoutRow: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "figure.run")
                    .font(.title3)
                    .foregroundColor(.red)
            }
            
            Text("Workouts completed")
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("-") {
                    withAnimation(.spring()) {
                        viewModel.decrementWorkouts()
                    }
                }
                .disabled(viewModel.workoutsCompleted <= 0)
                .buttonStyle(WorkoutButtonStyle(isEnabled: viewModel.workoutsCompleted > 0))
                
                Text("\(viewModel.workoutsCompleted)/2")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(minWidth: 30)
                
                Button("+") {
                    withAnimation(.spring()) {
                        viewModel.incrementWorkouts()
                    }
                }
                .disabled(viewModel.workoutsCompleted >= 2)
                .buttonStyle(WorkoutButtonStyle(isEnabled: viewModel.workoutsCompleted < 2))
            }
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(isEnabled ? .white : .gray)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(isEnabled ? Color.red : Color.gray.opacity(0.3))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct WaterTrackingRow: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @Binding var showingWaterEntry: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "drop.fill")
                        .font(.title3)
                        .foregroundColor(.cyan)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Water intake")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(viewModel.waterGoalText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Edit") {
                    showingWaterEntry = true
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.cyan)
            }
            
            // Water Progress Bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cyan.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, viewModel.waterProgressPercentage * 280), height: 8)
                    .animation(.spring(response: 0.6), value: viewModel.waterProgressPercentage)
            }
            .frame(maxWidth: 280)
        }
        .padding(.vertical, 4)
    }
}

struct SupplementsRow: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "pills.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                
                Text("Supplements")
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(viewModel.supplementsTaken.count)/\(viewModel.todaySupplements.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            if !viewModel.todaySupplements.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(viewModel.todaySupplements, id: \.id) { supplement in
                        SupplementPill(
                            supplement: supplement,
                            isCompleted: viewModel.isSupplementTaken(supplement)
                        ) {
                            withAnimation(.spring()) {
                                viewModel.toggleSupplement(supplement)
                            }
                        }
                    }
                }
            } else {
                Text("No supplements configured")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SupplementPill: View {
    let supplement: Supplement
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(supplement.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(supplement.dosage)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCompleted ? Color.green.opacity(0.1) : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionsCard: View {
    @Binding var showingCamera: Bool
    @Binding var showingJournal: Bool
    @Binding var showingCalendar: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                ModernQuickActionButton(
                    title: "Photo",
                    icon: "camera.fill",
                    gradient: LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    showingCamera = true
                }
                
                ModernQuickActionButton(
                    title: "Journal",
                    icon: "book.closed.fill",
                    gradient: LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    showingJournal = true
                }
                
                ModernQuickActionButton(
                    title: "Calendar",
                    icon: "calendar",
                    gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    showingCalendar = true
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernQuickActionButton: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MotivationalCard: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    private func getMotivationalHeadline(for day: Int) -> String {
        let headlines = [
            // Days 1-10: Starting Strong
            "Day 1: Mental Toughness Begins",
            "Day 2: You chose the hard path. Prove yourself right.",
            "Day 3: Discipline > Motivation",
            "Day 4: Champions are built in the grind",
            "Day 5: Your future self is counting on you",
            "Day 6: Comfort is the enemy of greatness",
            "Day 7: Week 1 complete. You're already uncommon.",
            "Day 8: Every rep counts. Every choice matters.",
            "Day 9: The pain you feel today builds tomorrow's strength",
            "Day 10: Double digits. You're not the same person who started.",
            
            // Days 11-20: Building Momentum
            "Day 11: Momentum is your new best friend",
            "Day 12: When it gets hard, you get harder",
            "Day 13: Lucky 13. Superstitions don't stop champions.",
            "Day 14: Two weeks of proof you can do hard things",
            "Day 15: Halfway through your first month of transformation",
            "Day 16: Your comfort zone is now in your rearview mirror",
            "Day 17: Excellence is not an act, but a habit",
            "Day 18: The person you're becoming is worth the pain",
            "Day 19: Mental toughness is your superpower",
            "Day 20: You've done the impossible 20 times in a row",
            
            // Days 21-30: First Month
            "Day 21: Habits are forming. You're rewiring your brain.",
            "Day 22: The grind doesn't get easier, you get stronger",
            "Day 23: Your discipline is becoming legendary",
            "Day 24: Almost a month of choosing hard over easy",
            "Day 25: Quarter century of commitment to excellence",
            "Day 26: You're not just surviving, you're thriving",
            "Day 27: The compound effect is working in your favor",
            "Day 28: Four weeks of proving yourself right",
            "Day 29: Tomorrow marks one month of mental toughness",
            "Day 30: 30 days of choosing yourself. This is who you are now.",
            
            // Days 31-40: Deepening
            "Day 31: Month 2 begins. You're a different person now.",
            "Day 32: Your old self wouldn't recognize you",
            "Day 33: The hardest battles are won in the mind",
            "Day 34: You're building character with every choice",
            "Day 35: Five weeks of relentless commitment",
            "Day 36: Your willpower is now your weapon",
            "Day 37: The struggle is where strength is born",
            "Day 38: You've normalized doing extraordinary things",
            "Day 39: Mental fortitude is your new identity",
            "Day 40: 40 days of choosing growth over comfort",
            
            // Days 41-50: Mid-Challenge Power
            "Day 41: You're in the zone where legends are made",
            "Day 42: Six weeks of proving impossible is just an opinion",
            "Day 43: Your consistency is your competitive advantage",
            "Day 44: The person in the mirror is a warrior",
            "Day 45: 45 days of mental toughness mastery",
            "Day 46: You've broken through every excuse",
            "Day 47: Your discipline inspires others",
            "Day 48: You're living proof that ordinary people do extraordinary things",
            "Day 49: 49 days of choosing hard. You're unstoppable.",
            "Day 50: Halfway there. Your transformation is undeniable.",
            
            // Days 51-60: Pushing Through
            "Day 51: The second half begins. Champions finish strong.",
            "Day 52: Your mental strength is now unbreakable",
            "Day 53: You've silenced every doubt",
            "Day 54: Eight weeks of choosing excellence",
            "Day 55: You're operating on a different level now",
            "Day 56: Your commitment has become your identity",
            "Day 57: The grind has made you extraordinary",
            "Day 58: You've mastered the art of not quitting",
            "Day 59: 59 days of proving your word is bond",
            "Day 60: 60 days of mental toughness. You're elite.",
            
            // Days 61-70: The Final Stretch
            "Day 61: The final push begins. Champions finish.",
            "Day 62: Your transformation is almost complete",
            "Day 63: Nine weeks of choosing hard over easy",
            "Day 64: You've rewritten your story",
            "Day 65: Your discipline has become your superpower",
            "Day 66: Two weeks left. This is when legends separate.",
            "Day 67: You've conquered every excuse and obstacle",
            "Day 68: Your commitment level is now legendary",
            "Day 69: 69 days of proving you don't quit",
            "Day 70: One week remains. You can taste victory.",
            
            // Days 71-75: Victory Lap
            "Day 71: The final week. Champions finish strong.",
            "Day 72: Three days left. Your transformation is complete.",
            "Day 73: You've become everything you said you would.",
            "Day 74: Tomorrow you join the 1% who finished.",
            "Day 75: CHAMPION. You did what most people can't. You finished."
        ]
        
        // Ensure we don't go out of bounds
        let index = min(max(day - 1, 0), headlines.count - 1)
        return headlines[index]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // FIXED: Proper SwiftUI modifiers for header
            Text("DAILY MINDSET")
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .tracking(2)
                .foregroundColor(.secondary)
            
            Rectangle()
                .fill(Color.primary)
                .frame(height: 1)
                .frame(maxWidth: 40)
            
            // Dynamic challenge-specific headline
            Text(getMotivationalHeadline(for: viewModel.currentDay))
                .font(.system(.body, design: .serif, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineSpacing(4)
                .padding(.horizontal, 4)
        }
        .padding(24)
        .background(
            Rectangle()
                .fill(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .stroke(Color(.separator), lineWidth: 1)
                )
        )
    }
}

// NEW: Camera-first photo capture view
struct CameraFirstPhotoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    let onPhotoTaken: () -> Void
    
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Progress Photo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Capture your transformation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Processing photo...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 24) {
                        // Camera Button (Primary)
                        Button {
                            showingCamera = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "camera")
                                    .font(.title2)
                                Text("Take Photo")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                        }
                        
                        // Gallery Button (Secondary)
                        Button {
                            showingGallery = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                Text("Choose from Gallery")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue, lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { image in
                    isLoading = true
                    processImage(image)
                }
            }
            .photosPicker(isPresented: $showingGallery, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { oldValue, newPhoto in
                if let newPhoto = newPhoto {
                    isLoading = true
                    processSelectedPhoto(newPhoto)
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        // Process camera image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.handlePhotoSelection()
            isLoading = false
            dismiss()
            onPhotoTaken()
        }
    }
    
    private func processSelectedPhoto(_ photo: PhotosPickerItem) {
        // Process gallery photo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.handlePhotoSelection()
            selectedPhoto = nil
            isLoading = false
            dismiss()
            onPhotoTaken()
        }
    }
}

// FIXED: Improved camera view with proper error handling
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
        // Update camera settings if needed
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

// FIXED: Preview challenge overview card with proper SwiftUI modifiers
struct PreviewChallengeCard: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("What this challenge includes")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // FIXED: Proper grid layout with correct spacing
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                PreviewHabitRow(icon: "book.fill", title: "Read 10 pages daily", color: .green)
                PreviewHabitRow(icon: "figure.run", title: "2 workouts per day", color: .red)
                PreviewHabitRow(icon: "drop.fill", title: "1 gallon of water", color: .cyan)
                PreviewHabitRow(icon: "camera.fill", title: "Daily progress photo", color: .blue)
                PreviewHabitRow(icon: "moon.fill", title: "7+ hours sleep", color: .purple)
                PreviewHabitRow(icon: "book.closed.fill", title: "Journal entry", color: .orange)
                PreviewHabitRow(icon: "pills.fill", title: "Supplements (optional)", color: .green)
            }
            
            VStack(spacing: 8) {
                Text("💪 Get Ready to Transform")
                    .font(.headline)
                    .fontWeight(.black)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("When your challenge starts, you'll track all these habits daily. Use this time to prepare mentally and gather any materials you need.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct PreviewHabitRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self, Supplement.self, ChallengeSettings.self, NotificationPreference.self], inMemory: true)
}