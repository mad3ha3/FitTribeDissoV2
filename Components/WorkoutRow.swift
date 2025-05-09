import SwiftUI

// shows a single workout row with details
struct WorkoutRow: View {
    let workout: Workout // workout data for this row
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                
                Spacer()
                
                if let duration = workout.duration, duration > 0 {
                    Text("\(duration) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let sets = workout.sets, let reps = workout.reps {
                    Text(" \(sets)x\(reps)") // shows the sets and reps
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(workout.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Add date display
                Text(workout.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
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

