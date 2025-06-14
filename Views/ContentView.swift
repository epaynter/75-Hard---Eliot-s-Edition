import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var hasRequestedNotifications = false
    
    var body: some View {
        CustomTabBar()
            .task {
                if !hasRequestedNotifications {
                    await requestNotificationPermissions()
                }
            }
    }
    
    private func requestNotificationPermissions() async {
        do {
            try await NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleNotifications()
            hasRequestedNotifications = true
        } catch {
            print("Failed to request notification permissions: \(error)")
        }
    }
} 