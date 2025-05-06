import SwiftUI

//this is for each workout type card that is shown
struct WorkoutTypeCardView: View {
    let type: String
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: onDelete) { //delete button for each workout type card
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            
            Image(systemName: "figure.mixed.cardio") //image on each card front 
                .font(.system(size: 40))
                .foregroundColor(Color("AppOrange"))
            
            Text(type) //each workout type card title is presented here
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
        
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
}

#Preview {
    WorkoutTypeCardView(type: "Custom Workout", onDelete: {})
        .padding()
        .background(Color(.systemGray6))
}
