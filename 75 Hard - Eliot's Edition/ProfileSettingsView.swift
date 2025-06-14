import SwiftUI
import SwiftData

struct ProfileSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingChallengeConfig = false
    @State private var showingAddSupplement = false
    @State private var showingResetAlert = false
    
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
                    
                    // Settings Cards
                    VStack(spacing: 16) {
                        // Challenge Configuration
                        SettingCard(
                            title: "Challenge Settings",
                            icon: "gear",
                            color: .blue
                        ) {
                            showingChallengeConfig = true
                        }
                        
                        // Notifications
                        SettingCard(
                            title: "Notifications",
                            icon: "bell",
                            color: .orange
                        ) {
                            // Handle notifications settings
                        }
                        
                        // Privacy
                        SettingCard(
                            title: "Privacy",
                            icon: "lock",
                            color: .purple
                        ) {
                            // Handle privacy settings
                        }
                        
                        // Export Data
                        SettingCard(
                            title: "Export Data",
                            icon: "square.and.arrow.up",
                            color: .green
                        ) {
                            // Handle data export
                        }
                        
                        // Help & Support
                        SettingCard(
                            title: "Help & Support",
                            icon: "questionmark.circle",
                            color: .cyan
                        ) {
                            // Handle help & support
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Extra padding for custom tab bar
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileSettingsView()
} 