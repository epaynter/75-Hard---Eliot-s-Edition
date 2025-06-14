import SwiftUI
import SwiftData

extension Notification.Name {
    static let supplementsChanged = Notification.Name("supplementsChanged")
}

struct SupplementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query private var supplements: [Supplement]
    @State private var showingAddSupplement = false
    @State private var newSupplementName = ""
    @State private var newSupplementDosage = ""
    @State private var newSupplementTime: SupplementTime = .morning
    
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark 
                ? [Color.orange.opacity(0.3), Color.red.opacity(0.2)]
                : [Color.orange.opacity(0.1), Color.red.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    // Title Icon
                    ZStack {
                        Circle()
                            .fill(headerGradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "pills.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Supplements")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Manage your daily supplement routine")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 24)
                
                // Current Supplements Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        Text("Your Supplements")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(supplements.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.1))
                            )
                    }
                    
                    if supplements.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "pills")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 8) {
                                Text("No supplements added")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add your daily supplements to track them in your challenge")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(supplements) { supplement in
                                SupplementRow(supplement: supplement) {
                                    deleteSupplement(supplement)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                
                // Add Supplement Button
                Button(action: {
                    showingAddSupplement = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        
                        Text("Add Supplement")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Tips Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        
                        Text("Tips")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TipRow(
                            icon: "clock.fill",
                            text: "Take supplements at the same time each day for consistency",
                            color: .blue
                        )
                        
                        TipRow(
                            icon: "water.waves",
                            text: "Most supplements are best absorbed with water",
                            color: .cyan
                        )
                        
                        TipRow(
                            icon: "checkmark.shield.fill",
                            text: "Check off supplements as you take them to track progress",
                            color: .green
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(
            LinearGradient(
                colors: colorScheme == .dark 
                    ? [Color.black, Color.gray.opacity(0.1)]
                    : [Color(.systemGroupedBackground), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .alert("Add Supplement", isPresented: $showingAddSupplement) {
            TextField("Supplement name", text: $newSupplementName)
            TextField("Dosage (e.g. 1000mg)", text: $newSupplementDosage)
            Picker("Time of Day", selection: $newSupplementTime) {
                ForEach(SupplementTime.allCases, id: \.self) { time in
                    Text(time.displayName).tag(time)
                }
            }
            Button("Add") {
                addSupplement()
            }
            .disabled(newSupplementName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                     newSupplementDosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {
                newSupplementName = ""
                newSupplementDosage = ""
                newSupplementTime = .morning
            }
        } message: {
            Text("Enter the details of the supplement you want to track daily.")
        }
    }
    
    private func addSupplement() {
        let trimmedName = newSupplementName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDosage = newSupplementDosage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty && !trimmedDosage.isEmpty else { return }
        
        let supplement = Supplement(
            name: trimmedName,
            dosage: trimmedDosage,
            timeOfDay: newSupplementTime
        )
        modelContext.insert(supplement)
        
        do {
            try modelContext.save()
            NotificationCenter.default.post(name: .supplementsChanged, object: nil)
        } catch {
            print("Error saving supplement: \(error)")
        }
        
        newSupplementName = ""
        newSupplementDosage = ""
        newSupplementTime = .morning
    }
    
    private func deleteSupplement(_ supplement: Supplement) {
        modelContext.delete(supplement)
        
        do {
            try modelContext.save()
            NotificationCenter.default.post(name: .supplementsChanged, object: nil)
        } catch {
            print("Error deleting supplement: \(error)")
        }
    }
}

struct SupplementRow: View {
    let supplement: Supplement
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pills.fill")
                .foregroundColor(.orange)
                .font(.title3)
                .frame(width: 24)
            
            Text(supplement.name)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        SupplementsView()
    }
} 