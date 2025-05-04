//
//  AddWorkoutView.swift
//  disso
//
//  Created by Madeha Ahmed on 14/04/2025.
//

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workoutViewModel: WorkoutViewModel
    let preselectedType: String
    
    @State private var workoutName = ""
    @State private var duration = 30
    @State private var caloriesBurned = 0
    @State private var notes = ""
    @State private var selectedDate = Date()
    @State private var sets = 3
    @State private var reps = 10
    
    init(workoutViewModel: WorkoutViewModel, preselectedType: String) {
        self.workoutViewModel = workoutViewModel
        self.preselectedType = preselectedType
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Workout Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Workout Details")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            TextField("Workout Name", text: $workoutName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.never)
                            
                            Text("Type: \(preselectedType)")
                                .foregroundColor(.secondary)
                            
                            if preselectedType.lowercased().contains("strength") {
                                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                                Stepper("Reps: \(reps)", value: $reps, in: 1...30)
                            } else {
                                Stepper("Duration: \(duration) minutes", value: $duration, in: 1...180)
                            }
                            
                            Stepper("Calories Burned: \(caloriesBurned)", value: $caloriesBurned, in: 0...2000, step: 50)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty)
                }
            }
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(
            name: workoutName,
            type: preselectedType,
            duration: preselectedType.lowercased().contains("strength") ? nil : duration,
            caloriesBurned: caloriesBurned,
            notes: notes,
            date: selectedDate,
            userId: "",
            sets: preselectedType.lowercased().contains("strength") ? sets : nil,
            reps: preselectedType.lowercased().contains("strength") ? reps : nil
        )
        
        Task {
            await workoutViewModel.addWorkout(workout: workout)
            dismiss()
        }
    }
}

#Preview {
    AddWorkoutView(
        workoutViewModel: WorkoutViewModel(),
        preselectedType: "Cardio"
    )
}


