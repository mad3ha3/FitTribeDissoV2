import SwiftUI

struct AddWorkoutTypeView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newTypeName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter workout type name", text: $newTypeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.words)
                    .padding()
                
                Button {
                    if !newTypeName.isEmpty {
                        Task {
                            await viewModel.addWorkoutType(type:
                                                            newTypeName)
                            dismiss()
                        }
                    }
                } label: {
                    Text("Add Workout Type")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(newTypeName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(newTypeName.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("New Workout Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
