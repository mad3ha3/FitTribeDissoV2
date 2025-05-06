import SwiftUI
import ConfettiSwiftUI //external open library used for confetti animation

// this is used to present each goal
struct GoalsView: View {
    @ObservedObject var goalsViewModel: GoalsViewModel
    @State var inputText: String = ""
    @State private var trigger: Int = 0 //trigger for confetti animation, when a goal is completed
    
    var body: some View {
        VStack {
            //load message is shown whilst the goals are being fetched
            if goalsViewModel.isLoading {
                ProgressView("Showing your goals...")
            }

            // small title about the goal period
            Text("You've got a month to complete your goals!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)

            List {
                ForEach(goalsViewModel.goals) { goal in
                    Button {
                        Task {
                            //trigger confetti if the goal is marked as completed
                            if !goal.isDone {
                                trigger += 1
                            }
                            await goalsViewModel.toggleCompletedGoal(goal: goal)
                        }
                    } label: {
                        HStack {
                            //checkbox icon used for goal ticking
                            Image(systemName: goal.isDone ? "checkmark.square.fill" : "square")
                                .resizable()
                                .frame(width: 24, height: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(goal.name)
                                Text(goal.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in //swipe to delete the goal
                    guard let index = indexSet.first else { return }
                    Task {
                        await goalsViewModel.deleteGoal(goal: goalsViewModel.goals[index])
                    }
                }
            }
            
            //input field at the bottom to add goals to the goal view
            HStack {
                TextField("Add a new goal", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    guard !inputText.isEmpty else { return }
                    Task {
                        await goalsViewModel.addGoal(name: inputText)
                        inputText = ""
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .confettiCannon( // open library used for confettii animation when goal is completed
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
    GoalsView(goalsViewModel: GoalsViewModel())
}


