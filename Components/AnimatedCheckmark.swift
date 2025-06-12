import SwiftUI

struct AnimatedCheckmark: View {
    let isCompleted: Bool
    let color: Color
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            // Trigger haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Trigger scale animation
            withAnimation(.easeOut(duration: 0.2)) {
                scale = 0.8
            }
            
            // Reset scale and call action
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.2)) {
                    scale = 1.0
                }
                action()
            }
        }) {
            ZStack {
                // Animate between empty circle and filled checkmark
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(color)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 32))
                        .foregroundColor(color.opacity(0.5))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(scale)
            .animation(.easeOut(duration: 0.2), value: isCompleted)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        AnimatedCheckmark(
            isCompleted: true,
            color: .green,
            action: { print("Completed checkmark tapped") }
        )
        
        AnimatedCheckmark(
            isCompleted: false,
            color: .blue,
            action: { print("Uncompleted checkmark tapped") }
        )
    }
    .padding()
}