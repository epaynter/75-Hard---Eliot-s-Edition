//
//  PhotoDetailView.swift
//  75 Hard - Eliot's Edition
//
//  Created by Eliot Paynter on 6/10/25.
//

import SwiftUI

struct PhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    @State private var tempWeight: String
    @State private var tempNote: String
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isNoteFocused: Bool
    
    init(viewModel: ChecklistViewModel) {
        self.viewModel = viewModel
        self._tempWeight = State(initialValue: viewModel.weight != nil ? String(format: "%.1f", viewModel.weight!) : "")
        self._tempNote = State(initialValue: viewModel.photoNote)
    }
    
    var progressGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(progressGradient)
                            
                            Text("Progress Photo")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Add details to track your transformation")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Photo Status
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                
                                Text("Photo taken for \(viewModel.selectedDate, style: .date)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Great job staying consistent! 📸")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        
                        // Weight Entry
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "scalemass.fill")
                                    .foregroundStyle(progressGradient)
                                    .font(.title2)
                                
                                Text("Weight (Optional)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Enter your weight", text: $tempWeight)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .keyboardType(.decimalPad)
                                    .focused($isWeightFocused)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Text("lbs")
                                                .font(.title3)
                                                .foregroundColor(.secondary)
                                                .padding(.trailing)
                                        }
                                    )
                                
                                Text("Track your weight to see progress over time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        
                        // Notes Entry
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundStyle(progressGradient)
                                    .font(.title2)
                                
                                Text("Notes (Optional)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("How are you feeling today?", text: $tempNote, axis: .vertical)
                                    .font(.body)
                                    .focused($isNoteFocused)
                                    .lineLimit(3...6)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                
                                Text("Add thoughts, feelings, or observations about your progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        
                        // Quick Note Suggestions
                        if tempNote.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Quick Suggestions")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                    ForEach(quickNoteSuggestions, id: \.self) { suggestion in
                                        Button(suggestion) {
                                            tempNote = suggestion
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.blue.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Motivational Section
                        VStack(spacing: 12) {
                            Text("💪 Keep Going!")
                                .font(.headline)
                                .fontWeight(.black)
                                .foregroundStyle(progressGradient)
                            
                            Text("Every photo is a step closer to your goal. You're building discipline and momentum!")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(progressGradient.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveData()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(progressGradient)
                }
            }
            .onTapGesture {
                isWeightFocused = false
                isNoteFocused = false
            }
        }
    }
    
    private let quickNoteSuggestions = [
        "Feeling strong today! 💪",
        "Noticed more energy",
        "Clothes fitting better",
        "Feeling motivated",
        "Challenging but worth it",
        "Seeing progress",
        "Feeling confident",
        "Ready for tomorrow"
    ]
    
    private func saveData() {
        // Save weight
        if let weight = Double(tempWeight), weight > 0 {
            viewModel.updateWeight(weight)
        } else {
            viewModel.updateWeight(nil)
        }
        
        // Save note
        viewModel.updatePhotoNote(tempNote)
    }
}

#Preview {
    PhotoDetailView(viewModel: ChecklistViewModel())
}