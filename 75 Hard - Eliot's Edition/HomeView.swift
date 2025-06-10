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
    @StateObject private var viewModel = ChecklistViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingJournal = false
    @State private var showingCalendar = false
    @State private var showingCamera = false
    @State private var showingSettings = false
    
    let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10)) ?? Date()
    
    var currentDay: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(1, min(days + 1, 75))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Day \(currentDay) of 75")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("LOCK IN")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Today's Progress")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(viewModel.todaysProgress * 100))%")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        ProgressView(value: viewModel.todaysProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Checklist
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Daily Checklist")
                            .font(.headline)
                        
                        ChecklistRow(
                            title: "Read 10 pages",
                            isCompleted: viewModel.hasRead,
                            icon: "book.fill"
                        ) {
                            viewModel.toggleRead()
                        }
                        
                        HStack {
                            Image(systemName: "figure.run")
                                .foregroundColor(viewModel.workoutsCompleted >= 2 ? .green : .gray)
                                .frame(width: 24)
                            
                            Text("Workouts completed")
                                .flex()
                            
                            HStack(spacing: 8) {
                                Button("-") {
                                    viewModel.decrementWorkouts()
                                }
                                .disabled(viewModel.workoutsCompleted <= 0)
                                
                                Text("\(viewModel.workoutsCompleted)/2")
                                    .frame(minWidth: 30)
                                
                                Button("+") {
                                    viewModel.incrementWorkouts()
                                }
                                .disabled(viewModel.workoutsCompleted >= 2)
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        ChecklistRow(
                            title: "Water drank",
                            isCompleted: viewModel.hasWater,
                            icon: "drop.fill"
                        ) {
                            viewModel.toggleWater()
                        }
                        
                        ChecklistRow(
                            title: "7+ hours sleep",
                            isCompleted: viewModel.hasSleep,
                            icon: "bed.double.fill"
                        ) {
                            viewModel.toggleSleep()
                        }
                        
                        ChecklistRow(
                            title: "Supplements taken",
                            isCompleted: viewModel.hasSupplements,
                            icon: "pills.fill"
                        ) {
                            viewModel.toggleSupplements()
                        }
                        
                        ChecklistRow(
                            title: "Photo taken",
                            isCompleted: viewModel.hasPhoto,
                            icon: "camera.fill"
                        ) {
                            viewModel.togglePhoto()
                        }
                        
                        ChecklistRow(
                            title: "Journaled",
                            isCompleted: viewModel.hasJournaled,
                            icon: "book.closed.fill"
                        ) {
                            viewModel.toggleJournaled()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick Actions
                    VStack(spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            QuickActionButton(
                                title: "Take Photo",
                                icon: "camera.fill",
                                color: .blue
                            ) {
                                showingCamera = true
                            }
                            
                            QuickActionButton(
                                title: "Journal",
                                icon: "book.closed.fill",
                                color: .green
                            ) {
                                showingJournal = true
                            }
                            
                            QuickActionButton(
                                title: "Calendar",
                                icon: "calendar",
                                color: .orange
                            ) {
                                showingCalendar = true
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
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
                    Text("Select Photo")
                }
            }
            .onChange(of: selectedPhoto) { newPhoto in
                if newPhoto != nil {
                    viewModel.handlePhotoSelection()
                    selectedPhoto = nil
                }
            }
        }
    }
}

struct ChecklistRow: View {
    let title: String
    let isCompleted: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isCompleted ? .green : .gray)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(12)
        }
    }
}

extension View {
    func flex() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [DailyChecklist.self, JournalEntry.self], inMemory: true)
}