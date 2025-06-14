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
                heroGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // NEW: Check if challenge is in preview mode (future start date)
                        if let settings = viewModel.challengeSettings, settings.hasFutureStart {
                            // Preview Mode Layout
                            VStack(spacing: 24) {
                                // Preview Header
                                VStack(spacing: 16) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 60))
                                        .foregroundStyle(progressGradient)
                                    
                                    Text("Your challenge starts in")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(settings.daysUntilStart)")
                                        .font(.system(size: 72, weight: .black, design: .rounded))
                                        .foregroundStyle(progressGradient)
                                    
                                    Text(settings.daysUntilStart == 1 ? "day" : "days")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(spacing: 8) {
                                        Text("Start Date: \(settings.startDate, style: .date)")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        
                                        if !settings.userAffirmation.isEmpty {
                                            Text("Your Why: \"\(settings.userAffirmation)\"")
                                                .font(.body)
                                                .italic()
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.primary)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                // Preview Challenge Overview
                                PreviewChallengeCard()
                                
                                // Motivational Quote Section
                                MotivationalCard()
                                
                                // Preview Actions
                                VStack(spacing: 16) {
                                    Button("Update Challenge Settings") {
                                        showingSettings = true
                                    }
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    
                                    Button("Start Challenge Today") {
                                        startChallengeToday()
                                    }
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(progressGradient)
                                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    )
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            // Regular Challenge Mode Layout (existing code)
                            // Hero Header
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("DAY \(viewModel.currentDay)")
                                            .font(.system(size: 48, weight: .black, design: .rounded))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        
                                        Text("of \(viewModel.totalDays)")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Day Navigation
                                    DayNavigationControls(viewModel: viewModel) {
                                        showingDayNavigation = true
                                    }
                                }
                                
                                // Challenge Title & Motivation
                                VStack(spacing: 8) {
                                    // NEW: Rotating motivational messages instead of static "Lock In"
                                    Text(getMotivationalMessage())
                                        .font(.title)
                                        .fontWeight(.black)
                                        .tracking(3)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                    
                                    if !Calendar.current.isDateInToday(viewModel.selectedDate) {
                                        Text(viewModel.selectedDate, style: .date)
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Progress Overview
                            ProgressOverviewCard(viewModel: viewModel)
                            
                            // Daily Checklist
                            ChecklistCard(viewModel: viewModel, showingWaterEntry: $showingWaterEntry, showingPhotoDetail: $showingPhotoDetail)
                            
                            // Quick Actions
                            QuickActionsCard(
                                showingCamera: $showingCamera,
                                showingJournal: $showingJournal,
                                showingCalendar: $showingCalendar
                            )
                            
                            // Motivational Quote Section
                            MotivationalCard()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Increased padding for custom tab bar
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.primary)
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
    private let quotes = [
        // UPDATED: More stoic quotes from disciplined leaders
        "Stay hard. - David Goggins",
        "Discipline equals freedom. - Jocko Willink", 
        "The path to success is massive, determined action. - Tony Robbins",
        "You are in danger of living a life so comfortable that you will die without realizing your true potential. - David Goggins",
        "Good. - Jocko Willink",
        "Extreme ownership. - Jocko Willink",
        "Progress equals happiness. - Tony Robbins",
        "The only person you are destined to become is the person you decide to be. - Ralph Waldo Emerson",
        "Don't limit your challenges, challenge your limits.",
        "If you want to be uncommon amongst uncommon people, you have to do what they won't do. - David Goggins",
        "The cave you fear to enter holds the treasure you seek. - Joseph Campbell",
        "What we do now echoes in eternity. - Marcus Aurelius",
        "You control your effort. You control your attitude. You control your response.",
        "The impediment to action advances action. What stands in the way becomes the way. - Marcus Aurelius"
    ]
    
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
            
            // FIXED: Proper SwiftUI modifiers for quote text
            Text(quotes.randomElement() ?? quotes[0])
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