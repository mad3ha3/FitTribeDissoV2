//
//  WorkoutView.swift
//  disso
//
//  Created by Madeha Ahmed on 14/04/2025.
//

import SwiftUI


// MARK: - Weekday Selector Component
// Weekday Selector scroll view for filtering workout by day
struct WeekdaySelector: View {
    @Binding var selectedDay: WeekDay
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(WeekDay.allCases, id: \.self) { day in
                WeekdayButton(
                    day: day,
                    isSelected: day == selectedDay,
                    action: { selectedDay = day }
                )
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

// MARK: - Day Button Component
//button representing an individual day of the week
struct WeekdayButton: View {
    let day: WeekDay
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44) // Minimum touch target size
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
        }
    }
}

// MARK: - Workout List Component
//displays a filtered list of workouts for a selected day
struct WorkoutList: View {
    let workouts: [Workout]
    let selectedDay: WeekDay
    
    var filteredWorkouts: [Workout] {
        workouts.filter { workout in
            Calendar.current.isDate(workout.date, inSameDayAs: selectedDay.date)
        }
    }
    
    var body: some View {
        List {
            if filteredWorkouts.isEmpty {
                Text("No workouts for \(selectedDay.rawValue)")
                    .foregroundColor(.secondary)
            } else {
                ForEach(filteredWorkouts) { workout in
                    WorkoutRow(workout: workout)
                }
            }
        }
        .listStyle(.plain)
        .padding()
    }
}

// MARK: - Workout Row Component
//shows a single workout row in the list
struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                
                Spacer()
                
                if workout.type == "Strength" {
                    if let sets = workout.sets, let reps = workout.reps {
                        Text("\(sets)x\(reps)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if let duration = workout.duration, duration > 0 {
                    Text("\(duration) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(workout.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(workout.caloriesBurned) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Types
//used for filtering workouts
enum WeekDay: String, CaseIterable {
    case sunday = "Sun"
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    
    //used to create the date for a given weekday - used in filters
    var date: Date {
        let calendar = Calendar.current
        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        let targetWeekday = self.weekdayNumber
        
        // Calculate days to add (can be negative for past days)
        let daysToAdd = targetWeekday - todayWeekday
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
    }
    
    // Helper property to get the weekday number (1 = Sunday, 2 = Monday, etc.)
    private var weekdayNumber: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    //returns todays weekday as weekday enum
    static var today: WeekDay {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Calendar returns 1 for Sunday, 2 for Monday, etc.
        let weekdays: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return weekdays[weekday - 1]
    }
}
