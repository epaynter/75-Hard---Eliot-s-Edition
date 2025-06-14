import SwiftUI

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

#Preview {
    ZStack {
        Color(.systemBackground)
        FABButton(isExpanded: false) {}
    }
} 