import SwiftUI

struct WorkoutTypeView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var showingAddWorkoutType = false
    @State private var typeToDelete: String? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(viewModel.workoutTypes, id: \.self) { type in
                        ZStack {
                            NavigationLink(destination: WorkoutDetailView(workoutType: type)) {
                                WorkoutTypeCardView(type: type) {
                                    typeToDelete = type
                                    showingDeleteAlert = true
                                }
                            }
                        }
                    }
                    
                    // Add Workout Type Button
                    Button {
                        showingAddWorkoutType = true
                    } label: {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("Add Workout Type")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Workout Types")
            .sheet(isPresented: $showingAddWorkoutType) {
                AddWorkoutTypeView(viewModel: viewModel)
            }
            .alert("Delete Workout Type", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let type = typeToDelete {
                        Task {
                            await viewModel.deleteWorkoutType(type: type)
                        }
                    }
                }
            } message: {
                if let type = typeToDelete {
                    Text("Are you sure you want to delete '\(type)'? This action cannot be undone.")
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    WorkoutTypeView(viewModel: WorkoutViewModel())
}
