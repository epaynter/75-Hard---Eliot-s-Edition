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
                ? [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.3)]
                : [Color(red: 0.95, green: 0.95, blue: 1.0), Color(red: 0.9, green: 0.9, blue: 0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var progressGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue, Color.purple],
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
                                Text("🔥 LOCK IN 🔥")
                                    .font(.title)
                                    .fontWeight(.black)
                                    .tracking(3)
                                
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
                        ChecklistCard(viewModel: viewModel, showingWaterEntry: $showingWaterEntry)
                        
                        // Quick Actions
                        QuickActionsCard(
                            showingCamera: $showingCamera,
                            showingJournal: $showingJournal,
                            showingCalendar: $showingCalendar
                        )
                        
                        // Motivational Quote Section
                        MotivationalCard()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
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
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(progressGradient)
                        
                        Text("Select Progress Photo")
                            .font(.headline)
                        
                        Text("Choose a photo to track your 75 Hard transformation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
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
                Text("Are you sure you want to navigate to another day?")
            }
            .onChange(of: selectedPhoto) { newPhoto in
                if newPhoto != nil {
                    viewModel.handlePhotoSelection()
                    selectedPhoto = nil
                    showingPhotoDetail = true
                }
            }
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
                        viewModel.togglePhoto()
                    }
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
        "Discipline is choosing between what you want now and what you want most.",
        "The pain of discipline weighs ounces. The pain of regret weighs tons.",
        "Success is the sum of small efforts repeated day in and day out.",
        "Don't put off tomorrow what you can do today.",
        "Your body can stand it. It's your mind you have to convince."
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            Text("💪 DAILY MOTIVATION")
                .font(.headline)
                .fontWeight(.black)
                .tracking(1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(quotes.randomElement() ?? quotes[0])
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self, Supplement.self, ChallengeSettings.self, NotificationPreference.self], inMemory: true)
}