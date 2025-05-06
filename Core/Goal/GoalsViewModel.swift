//
//  GoalsViewModel.swift
//  disso
//
//  Created by Madeha Ahmed on 02/05/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class GoalsViewModel: ObservableObject {
    @Published var goals: [Goal] = [] //stores the users goal
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var allGoals: Int = 0 // total goals
    @Published var completedGoals: Int = 0 // users completed goals
    
    private let db = Firestore.firestore()
    
    init() {
        Task{
            await fetchGoals() //auto fetches goals when vm is initialised
        }
    }
    
    func fetchGoals() async { //fetches users goals for the current user
        guard let userId = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user ID found")
            return 
        }
        
        isLoading = true
        
        do {
            //query goals and are ordered by time
            let snapshot = try await db.collection("goals")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            //each doc is converted into a Goal object
            self.goals = snapshot.documents.compactMap { doc in
                if let goal = try? doc.data(as: Goal.self) {
                    return goal
                } else {
                    return nil
                }
            }
            self.updateGoalCount() //this updates the goal counter
        } catch {
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateGoalCount() { //counts goals all and completed
        allGoals = goals.count
        completedGoals = goals.filter {$0.isDone }.count
    }
    

    func addGoal(name: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //new goal object is created
        let newGoal = Goal(
            id: nil,
            name: name,
            isDone: false,
            timestamp: Date(),
            userId: userId
        )
        
        do {
            let docRef = try db.collection("goals").addDocument(from: newGoal)
            // add the new goal to the array with its ID
            var goalWithId = newGoal
            goalWithId.id = docRef.documentID
            goals.append(goalWithId)
            updateGoalCount()
        } catch {
            errorMessage = "failed to add goal: \(error.localizedDescription)"
        }
    }
    
    func toggleCompletedGoal(goal: Goal) async {
        guard let id = goal.id else { return }
        
        var updatedGoal = goal
        updatedGoal.isDone.toggle()
        
        do {
            try db.collection("goals").document(id).setData(from: updatedGoal)
            // Update just this goal in the array
            if let index = goals.firstIndex(where: { $0.id == id }) {
                goals[index].isDone = updatedGoal.isDone
            }
            updateGoalCount() //this recalculated the completed goals
        } catch {
            errorMessage = "failed to toggle goal: \(error.localizedDescription)"
        }
    }
    
    func deleteGoal(goal: Goal) async {
        guard let id = goal.id else { return }
        
        do {
            try await db.collection("goals").document(id).delete()
            // Remove the goal from local array
            goals.removeAll { $0.id == id }
            updateGoalCount() //updates the count used on the goal progress bar
        } catch {
            errorMessage = "failed to delete goal: \(error.localizedDescription)"
        }
    }
}


    
   
