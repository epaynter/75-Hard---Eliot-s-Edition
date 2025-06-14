import SwiftUI
import SwiftData
import AuthenticationServices

// Dashboard Layout Settings View
struct DashboardLayoutSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("showDailyRing") private var showDailyRing = true
    @AppStorage("showWaterTracker") private var showWaterTracker = true
    @AppStorage("showWorkoutTracker") private var showWorkoutTracker = true
    @AppStorage("showSupplementsTracker") private var showSupplementsTracker = true
    @AppStorage("accentColorTheme") private var accentColorTheme = "Blue"
    @AppStorage("dailyMotivationType") private var dailyMotivationType = "Quote"
    
    private let accentColors = ["Blue", "Red", "Gray"]
    private let motivationTypes = ["Quote", "Prompt", "None"]
    
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.indigo.opacity(0.3), Color.blue.opacity(0.2)]
                : [Color.indigo.opacity(0.1), Color.blue.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    // Title Icon
                    ZStack {
                        Circle()
                            .fill(headerGradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "rectangle.grid.2x2")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.indigo)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Dashboard Layout")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Customize what appears on your home screen")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 24)
                
                // Dashboard Sections Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "square.grid.3x3.topleft.filled")
                            .foregroundColor(.indigo)
                            .font(.title2)
                        
                        Text("Dashboard Sections")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    VStack(spacing: 16) {
                        DashboardToggleRow(
                            title: "Daily Ring",
                            subtitle: "Progress circle showing today's completion",
                            icon: "circle.dashed",
                            color: .blue,
                            isOn: $showDailyRing
                        )
                        
                        DashboardToggleRow(
                            title: "Water Tracker",
                            subtitle: "Quick water logging and progress",
                            icon: "drop.fill",
                            color: .cyan,
                            isOn: $showWaterTracker
                        )
                        
                        DashboardToggleRow(
                            title: "Workout Tracker",
                            subtitle: "Exercise logging and completion status",
                            icon: "figure.run",
                            color: .green,
                            isOn: $showWorkoutTracker
                        )
                        
                        DashboardToggleRow(
                            title: "Supplements Tracker",
                            subtitle: "Daily supplement reminders and tracking",
                            icon: "pills.fill",
                            color: .orange,
                            isOn: $showSupplementsTracker
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                
                // Accent Color Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "paintpalette.fill")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        Text("Accent Color")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Text("Choose the primary color theme for your app")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        ForEach(accentColors, id: \.self) { color in
                            Button(action: {
                                accentColorTheme = color
                            }) {
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(color == "Blue" ? .blue :
                                                color == "Red" ? .red : .gray)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: accentColorTheme == color ? 3 : 0)
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    Text(color)
                                        .font(.caption)
                                        .fontWeight(accentColorTheme == color ? .semibold : .regular)
                                        .foregroundColor(accentColorTheme == color ? .primary : .secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer()
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                
                // Daily Motivation Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "quote.bubble.fill")
                            .foregroundColor(.pink)
                            .font(.title2)
                        
                        Text("Daily Motivation")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Text("Choose how you want to receive daily inspiration")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        ForEach(motivationTypes, id: \.self) { type in
                            Button(action: {
                                dailyMotivationType = type
                            }) {
                                HStack {
                                    Image(systemName: dailyMotivationType == type ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(dailyMotivationType == type ? .blue : .secondary)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(type)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Text(motivationDescription(for: type))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
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
    }
    
    private func motivationDescription(for type: String) -> String {
        switch type {
        case "Quote": return "Inspirational quotes to start your day"
        case "Prompt": return "Thought-provoking questions for reflection"
        case "None": return "No daily motivation messages"
        default: return ""
        }
    }
}

struct DashboardToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct DataPrivacyView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingResetAlert = false
    
    var body: some View {
        Form {
            Section("Data Management") {
                Button("Reset Progress") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
            }
            
            Section("Privacy") {
                NavigationLink("Privacy Settings") {
                    Text("Privacy Settings")
                        .navigationTitle("Privacy")
                }
            }
            
            Section("Export") {
                NavigationLink("Export Data") {
                    Text("Export Data")
                        .navigationTitle("Export Data")
                }
            }
        }
        .navigationTitle("Data & Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset All Progress", isPresented: $showingResetAlert) {
            Button("Reset Everything", role: .destructive) {
                resetAllProgress()
            }
            Button("Reset Only Data", role: .destructive) {
                resetDataOnly()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose what to reset:\n\n• Reset Everything: Deletes all data AND settings\n• Reset Only Data: Keeps challenge settings and supplements")
        }
    }
    
    private func resetAllProgress() {
        // Reset logic here
    }
    
    private func resetDataOnly() {
        // Reset logic here
    }
}

struct AboutSupportView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingMailComposer = false
    
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.mint.opacity(0.3), Color.green.opacity(0.2)]
                : [Color.mint.opacity(0.1), Color.green.opacity(0.05)],
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
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.mint)
                    }
                    VStack(spacing: 8) {
                        Text("About & Support")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("App info, support, and legal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)
                // App Info Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("App Information")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    VStack(spacing: 12) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("2.0.0")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Created by")
                            Spacer()
                            Text("Eliot Paynter")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Build")
                            Spacer()
                            Text("2025.06.10")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.body)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                // Support Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Support & Feedback")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Text("Need help or have suggestions? We'd love to hear from you!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    VStack(spacing: 12) {
                        SupportButton(
                            icon: "envelope.fill",
                            title: "Send Feedback",
                            subtitle: "Share your thoughts and suggestions",
                            color: .blue
                        ) {
                            sendFeedback()
                        }
                        SupportButton(
                            icon: "exclamationmark.triangle.fill",
                            title: "Report Issue",
                            subtitle: "Let us know about any problems",
                            color: .red
                        ) {
                            reportIssue()
                        }
                        SupportButton(
                            icon: "star.fill",
                            title: "Rate the App",
                            subtitle: "Help others discover this app",
                            color: .yellow
                        ) {
                            rateApp()
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                // Legal Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                        Text("Legal Information")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    VStack(spacing: 12) {
                        LegalButton(
                            title: "Privacy Policy",
                            icon: "lock.doc.fill"
                        ) {
                            openPrivacyPolicy()
                        }
                        LegalButton(
                            title: "Terms of Service",
                            icon: "doc.plaintext.fill"
                        ) {
                            openTermsOfService()
                        }
                        LegalButton(
                            title: "Open Source Licenses",
                            icon: "chevron.left.forwardslash.chevron.right"
                        ) {
                            openLicenses()
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                // Credits Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.mint)
                            .font(.title2)
                        Text("Credits")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Developed by Eliot Paynter")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("Inspired by Andy Frisella's original 75 Hard challenge.")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
    }
    private func sendFeedback() {
        // Open mail composer
        if let url = URL(string: "mailto:support@75hardeliot.com") {
            UIApplication.shared.open(url)
        }
    }
    private func reportIssue() {
        // Open issue tracker or mail
        if let url = URL(string: "mailto:support@75hardeliot.com?subject=Issue%20Report") {
            UIApplication.shared.open(url)
        }
    }
    private func rateApp() {
        // Open App Store rating page
        if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://75hardeliot.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    private func openTermsOfService() {
        if let url = URL(string: "https://75hardeliot.com/terms") {
            UIApplication.shared.open(url)
        }
    }
    private func openLicenses() {
        if let url = URL(string: "https://75hardeliot.com/licenses") {
            UIApplication.shared.open(url)
        }
    }
}

// Notifications View
struct NotificationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("morningReminderTime") private var morningReminderTime = "08:00"
    @AppStorage("eveningReminderTime") private var eveningReminderTime = "20:00"
    @AppStorage("waterRemindersEnabled") private var waterRemindersEnabled = true
    @AppStorage("workoutRemindersEnabled") private var workoutRemindersEnabled = true
    @AppStorage("supplementRemindersEnabled") private var supplementRemindersEnabled = true
    
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.purple.opacity(0.3), Color.pink.opacity(0.2)]
                : [Color.purple.opacity(0.1), Color.pink.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    // Title Icon
                    ZStack {
                        Circle()
                            .fill(headerGradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.purple)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Notifications")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Stay on track with personalized reminders")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 24)
                
                // Master Toggle Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        Text("Notification Settings")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Notifications")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("Allow the app to send you reminders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                    }
                    
                    if !notificationsEnabled {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text("Notifications are disabled. Enable them to receive helpful reminders.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                
                // Daily Reminders Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Daily Reminders")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Morning Check-in")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text("Start your day with intention")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(morningReminderTime)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.indigo)
                                .font(.title3)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Evening Reflection")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text("Review your progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(eveningReminderTime)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .opacity(notificationsEnabled ? 1.0 : 0.5)
                
                // Activity Reminders Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        Text("Activity Reminders")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    VStack(spacing: 16) {
                        NotificationToggleRow(
                            title: "Water Reminders",
                            subtitle: "Stay hydrated throughout the day",
                            icon: "drop.fill",
                            color: .cyan,
                            isOn: $waterRemindersEnabled,
                            isEnabled: notificationsEnabled
                        )
                        
                        NotificationToggleRow(
                            title: "Workout Reminders",
                            subtitle: "Don't miss your daily exercise",
                            icon: "figure.run",
                            color: .green,
                            isOn: $workoutRemindersEnabled,
                            isEnabled: notificationsEnabled
                        )
                        
                        NotificationToggleRow(
                            title: "Supplement Reminders",
                            subtitle: "Take your supplements on time",
                            icon: "pills.fill",
                            color: .orange,
                            isOn: $supplementRemindersEnabled,
                            isEnabled: notificationsEnabled
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .opacity(notificationsEnabled ? 1.0 : 0.5)
                
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
                            icon: "gear",
                            text: "Adjust notification times in your device Settings app",
                            color: .gray
                        )
                        
                        TipRow(
                            icon: "moon.zzz.fill",
                            text: "Enable Do Not Disturb to avoid late-night interruptions",
                            color: .indigo
                        )
                        
                        TipRow(
                            icon: "bell.slash.fill",
                            text: "You can disable specific reminders while keeping others active",
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
    }
}

struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .disabled(!isEnabled)
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
                .frame(width: 16)
                .padding(.top, 2)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ProfileSettingsView: View {
    // Authentication state - Sign in with Apple implemented
    @AppStorage("userDisplayName") private var userDisplayName: String = ""
    @AppStorage("userID") private var userID: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Profile & Settings")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Customize your experience")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Profile Header Section
                    ProfileHeaderView(
                        displayName: userDisplayName,
                        userID: userID,
                        isLoggedIn: isLoggedIn,
                        onSignInSuccess: { name, id in
                            userDisplayName = name.isEmpty ? "Anonymous" : name
                            userID = id
                            isLoggedIn = true
                        },
                        onSignOut: {
                            userDisplayName = ""
                            userID = ""
                            isLoggedIn = false
                        }
                    )
                    
                    // Settings Cards
                    VStack(spacing: 16) {
                        // Challenge Settings
                        NavigationLink(destination: ChallengeSettingsView()) {
                            SettingCardView(
                                title: "Challenge Settings",
                                icon: "target",
                                color: .blue
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Dashboard Layout
                        NavigationLink(destination: DashboardLayoutSettingsView()) {
                            SettingCardView(
                                title: "Dashboard Layout",
                                icon: "rectangle.grid.2x2",
                                color: .indigo
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Supplements
                        NavigationLink(destination: SupplementsView()) {
                            SettingCardView(
                                title: "Supplements",
                                icon: "pills.fill",
                                color: .green
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Notifications
                        NavigationLink(destination: NotificationsView()) {
                            SettingCardView(
                                title: "Notifications",
                                icon: "bell",
                                color: .orange
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Data & Privacy
                        NavigationLink(destination: DataPrivacyView()) {
                            SettingCardView(
                                title: "Data & Privacy",
                                icon: "lock.shield",
                                color: .red
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // About & Support
                        NavigationLink(destination: AboutSupportView()) {
                            SettingCardView(
                                title: "About & Support",
                                icon: "info.circle",
                                color: .cyan
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Extra padding for custom tab bar
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Profile Header Component
struct ProfileHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    let displayName: String
    let userID: String
    let isLoggedIn: Bool
    let onSignInSuccess: (String, String) -> Void
    let onSignOut: () -> Void
    
    @State private var isSigningIn = false
    @State private var showingSignOutAlert = false
    
    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.blue.opacity(0.3), Color.purple.opacity(0.2)]
                : [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Info Section
            HStack(spacing: 16) {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(headerGradient)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(isLoggedIn ? .blue : .secondary)
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(isLoggedIn && !displayName.isEmpty ? "Welcome back, \(displayName)" : "Not signed in")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if isLoggedIn {
                            Image(systemName: "applelogo")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Text(isLoggedIn 
                         ? "Connected with Apple ID" 
                         : "Sign in to connect with friends and sync across devices")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isLoggedIn {
                    Button("Sign Out") {
                        showingSignOutAlert = true
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                }
            }
            
            // Sign In Button (only shown when not logged in)
            if !isLoggedIn {
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        handleSignInWithApple(result: result)
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)
                .disabled(isSigningIn)
                .opacity(isSigningIn ? 0.6 : 1.0)
                .overlay(
                    Group {
                        if isSigningIn {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
        )
        .animation(.easeInOut(duration: 0.3), value: isLoggedIn)
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onSignOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out? You'll need to sign in again to access social features.")
        }
    }
    
    private func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        isSigningIn = true
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                // Construct display name from full name components
                var displayName = ""
                if let givenName = fullName?.givenName,
                   let familyName = fullName?.familyName {
                    displayName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
                } else if let givenName = fullName?.givenName {
                    displayName = givenName
                } else if let email = email {
                    // Use part of email as fallback
                    displayName = String(email.split(separator: "@").first ?? "User")
                }
                
                // Default to "Anonymous" if no name available
                if displayName.isEmpty {
                    displayName = "Anonymous"
                }
                
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onSignInSuccess(displayName, userIdentifier)
                        isSigningIn = false
                    }
                }
                
                print("✅ Sign in successful - User: \(displayName), ID: \(userIdentifier)")
            }
            
        case .failure(let error):
            DispatchQueue.main.async {
                isSigningIn = false
                print("❌ Sign in failed: \(error.localizedDescription)")
                
                // Handle specific error cases
                if let authError = error as? ASAuthorizationError {
                    switch authError.code {
                    case .canceled:
                        print("User canceled sign in")
                    case .failed:
                        print("Authorization failed")
                    case .invalidResponse:
                        print("Invalid response")
                    case .notHandled:
                        print("Not handled")
                    case .unknown:
                        print("Unknown error")
                    @unknown default:
                        print("Unknown authorization error")
                    }
                }
            }
        }
    }
}



// MARK: - Login Placeholder View
struct LoginPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.black, Color.gray.opacity(0.2)]
                : [Color(.systemGroupedBackground), Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 8) {
                            Text("Connect & Share")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Authentication system coming soon")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Additional Auth Methods Preview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Additional Login Options:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            AuthMethodRow(
                                icon: "envelope.fill",
                                title: "Email & Password",
                                subtitle: "Traditional account creation",
                                color: .blue
                            )
                            
                            AuthMethodRow(
                                icon: "phone.fill",
                                title: "Phone Number",
                                subtitle: "SMS verification login",
                                color: .green
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
                    )
                    
                    // Social Features Preview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Future Features:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "person.2.fill",
                                title: "Connect with Friends",
                                subtitle: "Share progress and encourage each other"
                            )
                            
                            FeatureRow(
                                icon: "chart.bar.fill",
                                title: "Leaderboards",
                                subtitle: "Compete with the community"
                            )
                            
                            FeatureRow(
                                icon: "trophy.fill",
                                title: "Achievements",
                                subtitle: "Unlock badges and rewards"
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .navigationTitle("Login & Social")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct AuthMethodRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "clock.fill")
                .font(.caption)
                .foregroundColor(.orange)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SettingCardView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    ProfileSettingsView()
} 