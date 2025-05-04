import SwiftUI
import ConfettiSwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State var inputText: String = ""
    @State private var trigger: Int = 0
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Showing your goals...")
            }
            List {
                ForEach(viewModel.goals) { goal in
                    Button {
                        Task {
                            if !goal.isDone {
                                trigger += 1
                            }
                            await viewModel.toggleCompletedGoal(goal: goal)
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
                        await viewModel.deleteGoal(goal: viewModel.goals[index])
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
        .confettiCannon(
            trigger: $trigger,
            num: 50,
            colors: [.purple, .orange],
            rainHeight: 1000,
            openingAngle: Angle(degrees: 0),
            closingAngle: Angle(degrees: 360),
            radius: 300
        )
    }
}

#Preview {
    GoalsView()
}


