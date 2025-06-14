import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showFABActions = false
    @State private var showLogWater = false
    @State private var showLogProtein = false
    @State private var showLogWorkout = false
    @State private var showQuickJournal = false
    
    var body: some View {
        ZStack {
            // Main Content
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    ProgressAnalyticsView()
                case 2:
                    SocialHubView()
                case 3:
                    ProfileSettingsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // FAB Background Overlay (for dismissing)
            if showFABActions {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showFABActions = false
                        }
                    }
            }
            
            // Custom Tab Bar
            VStack {
                Spacer()
                
                // FAB Actions (Floating Quick Actions)
                if showFABActions {
                    FABActionsView(
                        showLogWater: $showLogWater,
                        showLogProtein: $showLogProtein,
                        showLogWorkout: $showLogWorkout,
                        showQuickJournal: $showQuickJournal,
                        isVisible: showFABActions
                    )
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 100)
                }
                
                // Bottom Tab Bar
                HStack(spacing: 0) {
                    // Tab 1: Home
                    TabBarButton(
                        icon: "house.fill",
                        title: "Home",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                        if showFABActions {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showFABActions = false
                            }
                        }
                    }
                    
                    // Tab 2: Analytics
                    TabBarButton(
                        icon: "chart.bar.fill",
                        title: "Analytics",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                        if showFABActions {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showFABActions = false
                            }
                        }
                    }
                    
                    // FAB (Central Button)
                    FABButton(
                        isExpanded: showFABActions,
                        action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showFABActions.toggle()
                            }
                        }
                    )
                    .frame(width: 80)
                    
                    // Tab 3: Social
                    TabBarButton(
                        icon: "person.3.fill",
                        title: "Social",
                        isSelected: selectedTab == 2
                    ) {
                        selectedTab = 2
                        if showFABActions {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showFABActions = false
                            }
                        }
                    }
                    
                    // Tab 4: Profile
                    TabBarButton(
                        icon: "person.crop.circle.fill",
                        title: "Profile",
                        isSelected: selectedTab == 3
                    ) {
                        selectedTab = 3
                        if showFABActions {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showFABActions = false
                            }
                        }
                    }
                }
                .frame(height: 60)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
                        .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: -10)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 34) // Safe area padding
            }
            .zIndex(1) // Ensure tab bar stays on top
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // Modal presentations
        .sheet(isPresented: $showLogWater) {
            WaterEntryView(viewModel: {
                let vm = ChecklistViewModel()
                vm.setModelContext(modelContext)
                return vm
            }())
        }
        .sheet(isPresented: $showLogProtein) {
            LogProteinView()
        }
        .sheet(isPresented: $showLogWorkout) {
            LogWorkoutView()
        }
        .sheet(isPresented: $showQuickJournal) {
            QuickJournalEntryView()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            DailyChecklist.self,
            JournalEntry.self,
            Supplement.self,
            ChallengeSettings.self,
            NotificationPreference.self,
            CustomHabit.self,
            CustomHabitEntry.self,
            NutritionGoals.self,
            NutritionEntry.self,
            DailyNutritionSummary.self
        ])
} 