import SwiftUI

struct SocialHubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Social Hub")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Connect with the 75 Hard community")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Placeholder content
                    VStack(spacing: 16) {
                        SocialCard(
                            title: "Community Challenges",
                            description: "Join group challenges and stay motivated",
                            icon: "person.3.fill",
                            color: .blue
                        )
                        
                        SocialCard(
                            title: "Share Progress",
                            description: "Post your daily wins and inspire others",
                            icon: "square.and.arrow.up",
                            color: .green
                        )
                        
                        SocialCard(
                            title: "Find Accountability Partners",
                            description: "Connect with others on the same journey",
                            icon: "person.2.fill",
                            color: .purple
                        )
                        
                        SocialCard(
                            title: "Leaderboards",
                            description: "See how you rank against others",
                            icon: "trophy.fill",
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Extra padding for custom tab bar
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SocialCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    SocialHubView()
}