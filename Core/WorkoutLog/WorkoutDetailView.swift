import SwiftUI

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
            if workoutsForType.isEmpty {
                Text("No workouts logged for \(workoutType)")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(workoutsForType) { workout in
                    WorkoutRow(workout: workout)
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    Task {
                        await viewModel.deleteWorkout(workout: workoutsForType[index])
                    }
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
