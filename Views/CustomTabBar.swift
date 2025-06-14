import SwiftUI

struct CustomTabBar: View {
    @State private var selectedTab = 0
    @State private var showFABActions = false
    @State private var showLogWater = false
    @State private var showLogProtein = false
    @State private var showLogWorkout = false
    @State private var showQuickJournal = false
    
    private let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.8)
    
    var body: some View {
        ZStack {
            // Main Content
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    ProgressAnalyticsView()
                case 3:
                    SocialHubView()
                case 4:
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
                        withAnimation(springAnimation) {
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
                            withAnimation(springAnimation) {
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
                            withAnimation(springAnimation) {
                                showFABActions = false
                            }
                        }
                    }
                    
                    // FAB (Central Button)
                    FABButton(
                        isExpanded: showFABActions
                    ) {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(springAnimation) {
                            showFABActions.toggle()
                        }
                    }
                    .frame(width: 80)
                    
                    // Tab 4: Social
                    TabBarButton(
                        icon: "person.3.fill",
                        title: "Social",
                        isSelected: selectedTab == 3
                    ) {
                        selectedTab = 3
                        if showFABActions {
                            withAnimation(springAnimation) {
                                showFABActions = false
                            }
                        }
                    }
                    
                    // Tab 5: Profile
                    TabBarButton(
                        icon: "person.crop.circle.fill",
                        title: "Profile",
                        isSelected: selectedTab == 4
                    ) {
                        selectedTab = 4
                        if showFABActions {
                            withAnimation(springAnimation) {
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
        }
        // Modal presentations
        .sheet(isPresented: $showLogWater) {
            LogWaterView()
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

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FABButton: View {
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    .shadow(color: .purple.opacity(0.2), radius: 16, x: 0, y: 8)
                
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.spring(response: 0.4), value: isExpanded)
            }
        }
        .scaleEffect(isExpanded ? 1.1 : 1.0)
        .animation(.spring(response: 0.4), value: isExpanded)
        .buttonStyle(PlainButtonStyle())
    }
}

struct FABActionsView: View {
    @Binding var showLogWater: Bool
    @Binding var showLogProtein: Bool
    @Binding var showLogWorkout: Bool
    @Binding var showQuickJournal: Bool
    let isVisible: Bool
    
    private let actions = [
        FABAction(
            title: "Water",
            icon: "drop.fill",
            color: .cyan,
            index: 0
        ),
        FABAction(
            title: "Protein",
            icon: "leaf.fill",
            color: .green,
            index: 1
        ),
        FABAction(
            title: "Workout",
            icon: "figure.strengthtraining.traditional",
            color: .orange,
            index: 2
        ),
        FABAction(
            title: "Journal",
            icon: "book.closed.fill",
            color: .purple,
            index: 3
        )
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(actions.reversed(), id: \.title) { action in
                FABActionButton(
                    action: action,
                    isVisible: isVisible,
                    delay: Double(3 - action.index) * 0.08
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    switch action.index {
                    case 0: showLogWater = true
                    case 1: showLogProtein = true
                    case 2: showLogWorkout = true
                    case 3: showQuickJournal = true
                    default: break
                    }
                }
            }
        }
    }
}

struct FABAction {
    let title: String
    let icon: String
    let color: Color
    let index: Int
}

struct FABActionButton: View {
    let action: FABAction
    let isVisible: Bool
    let delay: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(action.color)
                        .frame(width: 44, height: 44)
                        .shadow(color: action.color.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: action.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Label
                Text(action.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                
                Spacer()
            }
            .frame(maxWidth: 200)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 20)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
            .delay(isVisible ? delay : 0),
            value: isVisible
        )
    }
}

#Preview {
    CustomTabBar()
}