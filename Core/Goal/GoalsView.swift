import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State var inputText: String = ""
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Showing your goals...")
            }
            List {
                ForEach(viewModel.goals) { goal in
                    Button {
                        Task {
                            await viewModel.toggleCompletedGoal(goal)
                        }
                    } label: {
                        HStack {
                            Image(systemName: goal.isDone ? "checkmark.square.fill" : "square")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text(goal.name)
                        }
                    }
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    Task {
                        await viewModel.deleteGoal(viewModel.goals[index])
                    }
                }
            }
            
            HStack {
                TextField("Add a new goal", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    guard !inputText.isEmpty else { return }
                    Task {
                        await viewModel.addGoal(name: inputText)
                        inputText = ""
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    GoalsView()
}


