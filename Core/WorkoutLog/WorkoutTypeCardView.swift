
import SwiftUI

struct WorkoutTypeCardView: View {
    let type: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.mixed.cardio")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(type)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text("Tap to view workouts")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    WorkoutTypeCardView(type: "Custom Workout")
        .padding()
        .background(Color(.systemGray6))
}
