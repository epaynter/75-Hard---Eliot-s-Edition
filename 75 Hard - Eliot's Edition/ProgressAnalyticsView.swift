import SwiftUI
import SwiftData

struct ProgressAnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Progress Analytics")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Track your 75 Hard journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // Analytics Cards
                VStack(spacing: 16) {
                    AnalyticsCard(
                        title: "Daily Completion Rate",
                        value: "78%",
                        icon: "chart.bar.fill",
                        color: .blue
                    )
                    
                    AnalyticsCard(
                        title: "Current Streak",
                        value: "12 days",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    AnalyticsCard(
                        title: "Water Average",
                        value: "132 oz",
                        icon: "drop.fill",
                        color: .cyan
                    )
                    
                    AnalyticsCard(
                        title: "Perfect Days",
                        value: "8",
                        icon: "star.fill",
                        color: .yellow
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // Extra padding for custom tab bar
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    ProgressAnalyticsView()
} 