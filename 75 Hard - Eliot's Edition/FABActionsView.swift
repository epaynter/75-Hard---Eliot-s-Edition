import SwiftUI

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
    ZStack {
        Color(.systemBackground)
        FABActionsView(
            showLogWater: .constant(false),
            showLogProtein: .constant(false),
            showLogWorkout: .constant(false),
            showQuickJournal: .constant(false),
            isVisible: true
        )
    }
} 