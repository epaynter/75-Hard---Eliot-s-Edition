//
//  LockInApp.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI
import SwiftData

@main
struct LockInApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .modelContainer(for: [
                        DailyChecklist.self,
                        JournalEntry.self,
                        Supplement.self,
                        ChallengeSettings.self,
                        NotificationPreference.self,
                        CustomHabit.self,
                        CustomHabitEntry.self
                    ])
                    .onAppear {
                        NotificationManager.shared.requestNotificationPermission()
                    }
            } else {
                OnboardingView()
                    .modelContainer(for: [
                        DailyChecklist.self,
                        JournalEntry.self,
                        Supplement.self,
                        ChallengeSettings.self,
                        NotificationPreference.self,
                        CustomHabit.self,
                        CustomHabitEntry.self
                    ])
            }
        }
        .modelContainer(for: [
            DailyChecklist.self,
            JournalEntry.self,
            Supplement.self,
            ChallengeSettings.self,
            NotificationPreference.self
        ])
    }
}

// NEW: Comprehensive onboarding flow
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var userAffirmation = ""
    @State private var challengeSettings: ChallengeSettings?
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Welcome Page
            OnboardingPageView(
                title: "Welcome to 75 Hard",
                subtitle: "Elite • Focused • Transformative",
                icon: "flame.fill",
                description: "Ready to become your best self? This isn't just another app – it's your transformation companion.",
                gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .tag(0)
            
            // Commitment Page
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Text("Are you ready to become your best self?")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 24) {
                    Text("This challenge requires:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 16) {
                        CommitmentRow(icon: "book.fill", text: "Reading 10 pages daily", color: .green)
                        CommitmentRow(icon: "figure.run", text: "2 workouts per day", color: .red)
                        CommitmentRow(icon: "drop.fill", text: "1 gallon of water", color: .cyan)
                        CommitmentRow(icon: "camera.fill", text: "Daily progress photo", color: .blue)
                        CommitmentRow(icon: "moon.fill", text: "7+ hours of sleep", color: .purple)
                        CommitmentRow(icon: "book.closed.fill", text: "Daily journaling", color: .orange)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 60)
            .tag(1)
            
            // Affirmation Page
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Text("I'm doing this because...")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personal why will fuel your discipline")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    TextField("Enter your reason...", text: $userAffirmation, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...5)
                        .padding(.horizontal)
                    
                    Text("Examples: \"To prove I can keep my word to myself\", \"To become mentally tougher\", \"To build unstoppable discipline\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 60)
            .tag(2)
            
            // Final Setup Page
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Text("Let's set up your challenge")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                
                ChallengeQuickSetup(challengeSettings: $challengeSettings)
                
                Button("Start My Transformation") {
                    completeOnboarding()
                }
                .font(.headline)
                .fontWeight(.bold)
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
                .disabled(userAffirmation.isEmpty)
                .opacity(userAffirmation.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 60)
            .tag(3)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .onAppear {
            challengeSettings = ChallengeSettings(startDate: Date(), duration: 75)
        }
    }
    
    private func completeOnboarding() {
        // Save user affirmation and challenge settings
        if let settings = challengeSettings {
            settings.userAffirmation = userAffirmation
            modelContext.insert(settings)
            
            do {
                try modelContext.save()
                hasCompletedOnboarding = true
            } catch {
                print("Error saving onboarding data: \(error)")
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let icon: String
    let description: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(gradient)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.black)
                    
                    Text(subtitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(gradient)
                        .tracking(2)
                }
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

struct CommitmentRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

struct ChallengeQuickSetup: View {
    @Binding var challengeSettings: ChallengeSettings?
    
    var body: some View {
        VStack(spacing: 16) {
            if let settings = challengeSettings {
                VStack(spacing: 12) {
                    HStack {
                        Text("Start Date")
                        Spacer()
                        Text(settings.startDate, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(settings.duration) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Water Goal")
                        Spacer()
                        Text("\(Int(settings.goalWaterOunces)) oz")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            Text("You can customize these settings later in the app")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
