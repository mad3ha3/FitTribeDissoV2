//
//  WorkoutListView.swift
//  disso
//
//  Created by Madeha Ahmed on 14/04/2025.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Workout List View
//shows a list of workouts for the selected day
struct WorkoutListView: View {
    let workouts: [Workout]
    let selectedDay: WeekDay
    
    var filteredWorkouts: [Workout] {
        workouts.filter { workout in
            Calendar.current.isDate(workout.date, inSameDayAs: selectedDay.date)
        }
    }
    
    var body: some View {
        if filteredWorkouts.isEmpty {
            VStack {
                Spacer()
                Text("No workouts for \(selectedDay.rawValue)")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        } else {
            List {
                ForEach(filteredWorkouts) { workout in
                    WorkoutRow(workout: workout)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    WorkoutListView(
        workouts: [
            Workout(
                name: "Morning Run",
                type: "Cardio",
                duration: 30,
                caloriesBurned: 300,
                notes: "Felt great!",
                date: Date(),
                userId: "preview"
            )
        ],
        selectedDay: .monday
    )
}
