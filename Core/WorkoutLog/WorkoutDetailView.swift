import SwiftUI

//handles the workout details view that is shown
struct WorkoutDetailView: View {
    let workoutType: String
    @StateObject var viewModel = WorkoutViewModel()
    @State private var showingAddWorkout = false
    
    // Filter workouts for this specific type
    var workoutsForType: [Workout] {
        viewModel.workouts.filter { $0.type == workoutType }
    }
    
    var body: some View {
        List {
            //this displays each workout that has been logged
            ForEach(workoutsForType) { workout in
                WorkoutRow(workout: workout)
            }
            //delete each workout, swipe to delete
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                Task {
                    await viewModel.deleteWorkout(workout: workoutsForType[index])
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(workoutType)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddWorkout = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutView(
                workoutViewModel: viewModel,
                preselectedType: workoutType
            )
        }
        .onAppear {
            Task {
                await viewModel.refreshWorkouts()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workoutType: "Cardio")
    }
}
