import SwiftUI

struct LogWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutType = ""
    @State private var duration = ""
    @State private var notes = ""
    @State private var selectedType: WorkoutType?
    
    enum WorkoutType: String, CaseIterable {
        case cardio = "Cardio"
        case strength = "Strength"
        case yoga = "Yoga"
        case running = "Running"
        case cycling = "Cycling"
        case swimming = "Swimming"
        case hiit = "HIIT"
        case sports = "Sports"
        
        var icon: String {
            switch self {
            case .cardio: return "heart.fill"
            case .strength: return "dumbbell.fill"
            case .yoga: return "figure.yoga"
            case .running: return "figure.run"
            case .cycling: return "bicycle"
            case .swimming: return "figure.pool.swim"
            case .hiit: return "bolt.fill"
            case .sports: return "sportscourt.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .cardio: return .red
            case .strength: return .orange
            case .yoga: return .purple
            case .running: return .blue
            case .cycling: return .green
            case .swimming: return .cyan
            case .hiit: return .pink
            case .sports: return .indigo
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Log Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Track your training session")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Workout Type Selection
                VStack(spacing: 16) {
                    Text("Workout Type")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            WorkoutTypeButton(
                                type: type,
                                isSelected: selectedType == type
                            ) {
                                selectedType = type
                                workoutType = type.rawValue
                            }
                        }
                    }
                }
                
                // Duration Entry
                VStack(spacing: 12) {
                    Text("Duration")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        TextField("Enter minutes", text: $duration)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        Text("min")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Notes (Optional)
                VStack(spacing: 12) {
                    Text("Notes (Optional)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Exercise details, reps, weight, etc.", text: $notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Log Workout") {
                        // TODO: Implement workout logging
                        dismiss()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .disabled(workoutType.isEmpty || duration.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct WorkoutTypeButton: View {
    let type: LogWorkoutView.WorkoutType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? type.color : .primary)
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? type.color : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? type.color.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LogWorkoutView()
}