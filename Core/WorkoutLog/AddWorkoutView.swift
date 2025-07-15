//
//  AddWorkoutView.swift
//  disso
//
//  Created by Madeha Ahmed on 14/04/2025.
//
import Foundation
import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workoutViewModel: WorkoutViewModel
    let preselectedType: String // type of workout that is passed from detail view
    
    //input for the add workout form states
    @State private var workoutName = ""
    @State private var duration = 0
    @State private var caloriesBurned = 0
    @State private var notes = ""
    @State private var selectedDate = Date()
    @State private var sets = 0
    @State private var reps = 0
    @State private var weight = 0
    
    init(workoutViewModel: WorkoutViewModel, preselectedType: String) {
        self.workoutViewModel = workoutViewModel
        self.preselectedType = preselectedType
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                //workout form section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Workout Details")
                        .font(.headline)
                        .padding(.horizontal)
                    //workout name
                    VStack(spacing: 16) {
                        TextField("Workout Name", text: $workoutName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                        // this is shown based on the name of the workout type card
                        Text("Type: \(preselectedType)")
                            .foregroundColor(.secondary)
                        //date picker for the workout date
                        DatePicker(
                            "Date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        
                        //inputs for the values for the workout details
                        Stepper("Duration: \(duration) minutes", value: $duration, in: 1...Int.max)
                        Stepper("Sets: \(sets)", value: $sets, in: 0...Int.max)
                        Stepper("Reps: \(reps)", value: $reps, in: 0...Int.max)
                        Stepper("Weight: \(weight) kg", value: $weight, in: 0...Int.max)
                        Stepper("Calories Burned: \(caloriesBurned)", value: $caloriesBurned, in: 0...2000, step: 50)
                    }
                    .padding(.horizontal)
                }
                
                //add notes section
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
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                //cancel button doesnt save the workout
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    //saves the workout
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty)
                }
            }
        }
    }
    
    //save the workout
    private func saveWorkout() {
        let workout = Workout(
            name: workoutName,
            type: preselectedType,
            duration: duration,
            caloriesBurned: caloriesBurned,
            notes: notes,
            date: selectedDate,
            userId: "",
            sets: sets,
            reps: reps,
            weight: weight
        )
        //saves and closes the view
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


