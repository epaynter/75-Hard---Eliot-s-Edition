import SwiftUI

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

#Preview {
    HStack {
        TabBarButton(icon: "house.fill", title: "Home", isSelected: true) {}
        TabBarButton(icon: "chart.bar.fill", title: "Analytics", isSelected: false) {}
    }
    .padding()
    .background(Color(.systemBackground))
} 