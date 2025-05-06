import SwiftUI

//view for adding a workout type
struct AddWorkoutTypeView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newTypeName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter workout type name", text: $newTypeName) //test field to enter wrokout type name
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.words) // auto capitalises the type
                    .padding()
                
                //add new workout type button
                Button { //only shown if type is entered by user
                    if !newTypeName.isEmpty {
                        Task {
                            await viewModel.addWorkoutType(type: newTypeName)
                            dismiss()
                        }
                    }
                } label: {
                    Text("Add Workout Type")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(newTypeName.isEmpty ? Color.gray : Color.cyan)
                        .cornerRadius(10)
                }
                .disabled(newTypeName.isEmpty)
                .padding(.horizontal)
                
                Spacer()// displays this at the top
            }
            .navigationTitle("New Workout Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    //this dismisses the view without saving the workout type
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddWorkoutTypeView(viewModel: WorkoutViewModel())
} 
