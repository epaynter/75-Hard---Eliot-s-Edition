import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var hasRequestedNotifications = false
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            
            PhotoPickerView()
                .tabItem {
                    Label("Photos", systemImage: "photo.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
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