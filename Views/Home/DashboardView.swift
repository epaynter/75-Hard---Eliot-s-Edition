import SwiftUI

struct DashboardView: View {
    // Dashboard Layout Settings
    @AppStorage("showDailyRing") private var showDailyRing = true
    @AppStorage("showWaterTracker") private var showWaterTracker = true
    @AppStorage("showWorkoutTracker") private var showWorkoutTracker = true
    @AppStorage("showSupplementsTracker") private var showSupplementsTracker = true
    @AppStorage("accentColorTheme") private var accentColorTheme = "Blue"
    @AppStorage("dailyMotivationType") private var dailyMotivationType = "Quote"
    
    var accentColor: Color {
        switch accentColorTheme {
        case "Red": return .red
        case "Gray": return .gray
        default: return .blue
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Daily Ring
                if showDailyRing {
                    DailyRingView()
                        .accentColor(accentColor)
                }
                
                // Daily Motivation
                if dailyMotivationType != "None" {
                    DailyMotivationView(type: dailyMotivationType)
                        .accentColor(accentColor)
                }
                
                // Water Tracker
                if showWaterTracker {
                    WaterTrackerCard()
                        .accentColor(accentColor)
                }
                
                // Workout Tracker
                if showWorkoutTracker {
                    WorkoutTrackerCard()
                        .accentColor(accentColor)
                }
                
                // Supplements Tracker
                if showSupplementsTracker {
                    SupplementsTrackerCard()
                        .accentColor(accentColor)
                }
            }
            .padding()
        }
    }
}

struct DailyRingView: View {
    var body: some View {
        VStack {
            Text("Daily Progress")
                .font(.headline)
            // Add your daily ring implementation here
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct DailyMotivationView: View {
    let type: String
    
    var body: some View {
        VStack {
            Text(type == "Quote" ? "Daily Quote" : "Daily Prompt")
                .font(.headline)
            // Add your motivation content here
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct WaterTrackerCard: View {
    var body: some View {
        VStack {
            Text("Water Intake")
                .font(.headline)
            // Add your water tracker implementation here
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct WorkoutTrackerCard: View {
    var body: some View {
        VStack {
            Text("Workout Progress")
                .font(.headline)
            // Add your workout tracker implementation here
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct SupplementsTrackerCard: View {
    var body: some View {
        VStack {
            Text("Supplements")
                .font(.headline)
            // Add your supplements tracker implementation here
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    DashboardView()
} 