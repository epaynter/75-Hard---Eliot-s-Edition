import SwiftUI
import SwiftData

struct DataManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingExportAlert = false
    @State private var showingDeleteAlert = false
    @State private var exportMessage = ""
    
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.teal.opacity(0.3), Color.cyan.opacity(0.2)]
                : [Color.teal.opacity(0.1), Color.cyan.opacity(0.05)],
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
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.teal)
                    }
                    VStack(spacing: 8) {
                        Text("Data & Privacy")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Manage your data and privacy settings")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 24)
                // Data Export Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("Export Data")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Text("Download a copy of all your challenge data including progress, journal entries, and settings.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button(action: {
                        exportData()
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title3)
                            Text("Export My Data")
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
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                // Privacy Information Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        Text("Privacy Protection")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        PrivacyRow(
                            icon: "iphone",
                            title: "Local Storage",
                            description: "All data is stored locally on your device",
                            color: .blue
                        )
                        PrivacyRow(
                            icon: "wifi.slash",
                            title: "No Cloud Sync",
                            description: "Your personal data never leaves your device",
                            color: .green
                        )
                        PrivacyRow(
                            icon: "eye.slash.fill",
                            title: "No Tracking",
                            description: "We don't collect or share your personal information",
                            color: .purple
                        )
                        PrivacyRow(
                            icon: "lock.fill",
                            title: "Secure",
                            description: "Protected by iOS security and encryption",
                            color: .orange
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                // Data Management Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        Text("Data Management")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Text("Permanently delete all your data and settings from this device. This action cannot be undone.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .font(.title3)
                            Text("Reset Everything")
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
                                        colors: [.red, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
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
                            icon: "icloud.and.arrow.up",
                            text: "Export your data regularly to keep a backup",
                            color: .blue
                        )
                        TipRow(
                            icon: "iphone.and.arrow.forward",
                            text: "Use device backup to transfer data to a new phone",
                            color: .green
                        )
                        TipRow(
                            icon: "exclamationmark.triangle.fill",
                            text: "Deleting data is permanent and cannot be recovered",
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
        .alert("Export Complete", isPresented: $showingExportAlert) {
            Button("OK") { }
        } message: {
            Text(exportMessage)
        }
        .alert("Reset Everything", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                resetEverything()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all your challenge data, journal entries, supplements, settings, and progress. This action cannot be undone.")
        }
    }
    private func exportData() {
        // Simulate data export
        exportMessage = "Your data has been exported successfully. Check your Files app for the exported data."
        showingExportAlert = true
    }
    private func resetEverything() {
        do {
            // Delete all SwiftData models
            try modelContext.delete(model: DailyChecklist.self)
            try modelContext.delete(model: JournalEntry.self)
            try modelContext.delete(model: ChallengeSettings.self)
            try modelContext.delete(model: Supplement.self)
            try modelContext.delete(model: NotificationPreference.self)
            try modelContext.delete(model: CustomHabit.self)
            try modelContext.delete(model: CustomHabitEntry.self)
            try modelContext.delete(model: NutritionGoals.self)
            try modelContext.delete(model: NutritionEntry.self)
            try modelContext.delete(model: DailyNutritionSummary.self)
            // Reset all @AppStorage keys
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
            try modelContext.save()
        } catch {
            print("Error resetting everything: \(error)")
        }
    }
}

struct PrivacyRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DataManagementView()
    }
} 