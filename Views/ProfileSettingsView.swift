import SwiftUI

struct ProfileSettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    VStack(spacing: 16) {
                        // Profile Picture Placeholder
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Your Name")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Day 12 of 75")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Stats Section
                    HStack(spacing: 20) {
                        StatCard(title: "Perfect Days", value: "8")
                        StatCard(title: "Current Streak", value: "3")
                        StatCard(title: "Completion", value: "78%")
                    }
                    
                    // Settings Section
                    VStack(spacing: 12) {
                        SettingRow(
                            title: "Challenge Settings",
                            icon: "gear",
                            color: .blue
                        )
                        
                        SettingRow(
                            title: "Notifications",
                            icon: "bell",
                            color: .orange
                        )
                        
                        SettingRow(
                            title: "Privacy",
                            icon: "lock",
                            color: .purple
                        )
                        
                        SettingRow(
                            title: "Export Data",
                            icon: "square.and.arrow.up",
                            color: .green
                        )
                        
                        SettingRow(
                            title: "Help & Support",
                            icon: "questionmark.circle",
                            color: .cyan
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Extra padding for custom tab bar
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct SettingRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    ProfileSettingsView()
}