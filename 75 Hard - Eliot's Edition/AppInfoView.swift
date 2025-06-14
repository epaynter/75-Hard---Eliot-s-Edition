import SwiftUI

struct AppInfoView: View {
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
                    // App Icon
                    ZStack {
                        Circle()
                            .fill(headerGradient)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.mint)
                    }
                    
                    VStack(spacing: 8) {
                        Text("75 Hard - Eliot's Edition")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)
                
                // App Information Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("About This App")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Text("75 Hard - Eliot's Edition is a personal challenge tracker designed to help you build mental toughness and discipline through consistent daily habits.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(
                            icon: "target",
                            title: "Challenge Tracking",
                            description: "Monitor your daily progress across all challenge requirements",
                            color: .blue
                        )
                        
                        InfoRow(
                            icon: "book.fill",
                            title: "Journal Integration",
                            description: "Reflect on your journey with built-in journaling",
                            color: .purple
                        )
                        
                        InfoRow(
                            icon: "heart.fill",
                            title: "Health Integration",
                            description: "Sync with Apple Health for seamless tracking",
                            color: .red
                        )
                        
                        InfoRow(
                            icon: "shield.fill",
                            title: "Privacy First",
                            description: "All your data stays private on your device",
                            color: .green
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
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
                
                // Legal Information Card
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
                        Text("Developed with ❤️ by Eliot Paynter")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("Special thanks to Andy Frisella for creating the original 75 Hard challenge that inspired this app.")
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
        .navigationTitle("About & Support")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func sendFeedback() {
        // Implement feedback functionality
        print("Send feedback tapped")
    }
    
    private func reportIssue() {
        // Implement issue reporting
        print("Report issue tapped")
    }
    
    private func rateApp() {
        // Implement app rating
        print("Rate app tapped")
    }
    
    private func openPrivacyPolicy() {
        // Open privacy policy
        print("Privacy policy tapped")
    }
    
    private func openTermsOfService() {
        // Open terms of service
        print("Terms of service tapped")
    }
    
    private func openLicenses() {
        // Open licenses
        print("Licenses tapped")
    }
}

struct InfoRow: View {
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

struct SupportButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LegalButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .font(.body)
                    .frame(width: 20)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        AppInfoView()
    }
} 