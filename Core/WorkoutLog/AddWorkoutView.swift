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
    let selectedDay: WeekDay
    
    @State private var workoutName = ""
    @State private var workoutType = "Cardio"
    @State private var duration = 30
    @State private var caloriesBurned = 0
    @State private var notes = ""
    @State private var selectedDate: Date
    @State private var sets = 3
    @State private var reps = 10
    
    let workoutTypes = ["Cardio", "Strength", "Flexibility", "HIIT", "Yoga"]
    
    init(workoutViewModel: WorkoutViewModel, selectedDay: WeekDay) {
        self.workoutViewModel = workoutViewModel
        self.selectedDay = selectedDay
        _selectedDate = State(initialValue: selectedDay.date)
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
                            
                            Picker("Workout Type", selection: $workoutType) {
                                ForEach(workoutTypes, id: \.self) { type in
                                    Text(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                            
                            if workoutType == "Strength" {
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
            type: workoutType,
            duration: workoutType == "Strength" ? nil : duration,
            caloriesBurned: caloriesBurned,
            notes: notes,
            date: selectedDate,
            userId: "", // Will be set in the ViewModel
            sets: workoutType == "Strength" ? sets : nil,
            reps: workoutType == "Strength" ? reps : nil
        )
        
        Task {
            await workoutViewModel.addWorkout(workout)
            dismiss() // Only dismiss after the workout is added
        }
    }
}

#Preview {
    AddWorkoutView(workoutViewModel: WorkoutViewModel(), selectedDay: .monday)
}


