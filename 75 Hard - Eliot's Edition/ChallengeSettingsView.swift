import SwiftUI
import SwiftData

struct ChallengeSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var challengeSettings: ChallengeSettings?
    @State private var showingConfig = false

    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.blue.opacity(0.3), Color.purple.opacity(0.2)]
                : [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(headerGradient)
                            .frame(width: 80, height: 80)
                        Image(systemName: "target")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    VStack(spacing: 8) {
                        Text("Challenge Settings")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Adjust your goals and timeframe for this challenge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 24)
                // Challenge Overview Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("Current Challenge")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    if let settings = challengeSettings {
                        VStack(spacing: 12) {
                            SettingRow(
                                title: "Start Date",
                                value: settings.startDate.formatted(date: .abbreviated, time: .omitted),
                                icon: "calendar",
                                color: .blue
                            )
                            SettingRow(
                                title: "Duration",
                                value: "\(settings.duration) days",
                                icon: "timer",
                                color: .green
                            )
                            SettingRow(
                                title: "Water Goal",
                                value: "\(Int(settings.goalWaterOunces)) oz",
                                icon: "drop.fill",
                                color: .cyan
                            )
                            SettingRow(
                                title: "End Date",
                                value: settings.endDate.formatted(date: .abbreviated, time: .omitted),
                                icon: "flag.checkered",
                                color: .orange
                            )
                            if !settings.userAffirmation.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        Text("Your Why")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    Text("\"\(settings.userAffirmation)\"")
                                        .font(.body)
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 20)
                                }
                                .padding(.top, 8)
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("No challenge configured")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Set up your challenge to get started")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                // Action Button
                Button(action: {
                    showingConfig = true
                }) {
                    HStack {
                        Image(systemName: challengeSettings == nil ? "plus.circle.fill" : "pencil.circle.fill")
                            .font(.title3)
                        Text(challengeSettings == nil ? "Set Up Challenge" : "Edit Challenge")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                // Tips Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        Text("Tips")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        TipRow(
                            icon: "calendar.badge.plus",
                            text: "Start dates can be set in the future to prepare ahead",
                            color: .blue
                        )
                        TipRow(
                            icon: "drop.circle",
                            text: "Adjust water goals based on your body weight and activity level",
                            color: .cyan
                        )
                        TipRow(
                            icon: "heart.text.square",
                            text: "Your 'why' will be shown during tough moments for motivation",
                            color: .red
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(
            LinearGradient(
                colors: colorScheme == .dark 
                    ? [Color.black, Color.gray.opacity(0.1)]
                    : [Color(.systemGroupedBackground), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            loadSettings()
        }
        .sheet(isPresented: $showingConfig) {
            ChallengeConfigView(challengeSettings: challengeSettings) { newSettings in
                challengeSettings = newSettings
                saveChallengeSettings()
            }
        }
    }
    private func loadSettings() {
        let settingsDescriptor = FetchDescriptor<ChallengeSettings>()
        do {
            let settings = try modelContext.fetch(settingsDescriptor)
            challengeSettings = settings.first
        } catch {
            print("Error loading challenge settings: \(error)")
        }
    }
    private func saveChallengeSettings() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving challenge settings: \(error)")
        }
    }
}

struct SettingRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        ChallengeSettingsView()
    }
} 