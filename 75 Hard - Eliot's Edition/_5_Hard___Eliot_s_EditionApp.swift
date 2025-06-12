//
//  LockInApp.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI
import SwiftData
import HealthKit

@main
struct LockInApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
                    .modelContainer(for: [
                        DailyChecklist.self,
                        JournalEntry.self,
                        Supplement.self,
                        ChallengeSettings.self,
                        NotificationPreference.self,
                        CustomHabit.self,
                        CustomHabitEntry.self,
                        NutritionGoals.self,
                        NutritionEntry.self,
                        DailyNutritionSummary.self
                    ])
                    .onAppear {
                        NotificationManager.shared.requestNotificationPermission()
                        // Request HealthKit permission if available
                        Task {
                            await HealthKitManager.shared.requestHealthKitPermission()
                        }
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
                        CustomHabitEntry.self,
                        NutritionGoals.self,
                        NutritionEntry.self,
                        DailyNutritionSummary.self
                    ])
            }
        }
    }
}

// NEW: Comprehensive onboarding flow
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var userAffirmation = ""
    @State private var challengeSettings: ChallengeSettings?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 24) {
                    // Headline
                    Text("Start Your Challenge")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    // Why question prompt
                    Text("Why are you doing this?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    // Multiline text input
                    VStack(spacing: 8) {
                        TextEditor(text: $userAffirmation)
                            .frame(height: 120)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                            )
                            .overlay(
                                Group {
                                    if userAffirmation.isEmpty {
                                        Text("Write your personal motivation here...")
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .allowsHitTesting(false)
                                            .padding(.top, 20)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    // Challenge setup section
                    VStack(spacing: 16) {
                        Text("Challenge Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        ChallengeQuickSetup(challengeSettings: $challengeSettings)
                    }
                    
                    // Start button
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
        }
        .onTapGesture {
            hideKeyboard()
        }
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

// NEW: Helper components for improved onboarding experience
struct PromptSuggestionButton: View {
    let text: String
    @Binding var userAffirmation: String
    
    var body: some View {
        Button(action: {
            userAffirmation = text
            hideKeyboard()
        }) {
            Text(text)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// FIXED: Keyboard dismissal extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
