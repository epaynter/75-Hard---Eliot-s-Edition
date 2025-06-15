import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var hasRequestedNotifications = false
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("COMMAND", systemImage: "shield.fill")
                }
            
            CalendarView()
                .tabItem {
                    Label("BATTLE MAP", systemImage: "calendar.badge.clock")
                }
            
            JournalView()
                .tabItem {
                    Label("MISSION LOG", systemImage: "book.closed.fill")
                }
            
            PhotoPickerView()
                .tabItem {
                    Label("INTEL", systemImage: "camera.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("ARSENAL", systemImage: "gearshape.2.fill")
                }
        }
        .preferredColorScheme(.dark) // Force dark mode for warrior aesthetic
        .accentColor(DesignSystem.Colors.accent) // Use warrior accent color
        .onAppear {
            configureWarriorTabBar()
        }
        .task {
            if !hasRequestedNotifications {
                await requestNotificationPermissions()
            }
        }
    }
    
    private func configureWarriorTabBar() {
        // Configure tab bar appearance for warrior theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DesignSystem.Colors.backgroundSecondary)
        
        // Selected tab styling
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.Colors.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.accent),
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        
        // Unselected tab styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(DesignSystem.Colors.textTertiary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.textTertiary),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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