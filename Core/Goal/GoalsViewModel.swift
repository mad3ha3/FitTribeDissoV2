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
    @Published var goals: [Goal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        Task{
            await fetchGoals()
        }
    }
    
    func fetchGoals() async {
        guard let userId = Auth.auth().currentUser?.uid else { 
            print("DEBUG: No user ID found")
            return 
        }
        
        isLoading = true
        print("DEBUG: Starting to fetch goals for user: \(userId)")
        
        do {
            let snapshot = try await db.collection("goals")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            print("DEBUG: Found \(snapshot.documents.count) goals")
            
            self.goals = snapshot.documents.compactMap { doc in
                if let goal = try? doc.data(as: Goal.self) {
                    print("DEBUG: Successfully decoded goal: \(goal.name)")
                    return goal
                } else {
                    print("DEBUG: Failed to decode goal document")
                    return nil
                }
            }
            print("DEBUG: Successfully loaded \(self.goals.count) goals")
        } catch {
            print("DEBUG: Error fetching goals: \(error.localizedDescription)")
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func addGoal(name: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newGoal = Goal(
            id: nil,
            name: name,
            isDone: false,
            timestamp: Date(),
            userId: userId
        )
        
        do {
            let docRef = try db.collection("goals").addDocument(from: newGoal)
            // Add the new goal to the array with its ID
            var goalWithId = newGoal
            goalWithId.id = docRef.documentID
            goals.append(goalWithId)
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
        } catch {
            errorMessage = "failed to toggle goal: \(error.localizedDescription)"
        }
    }
    
    func deleteGoal(goal: Goal) async {
        guard let id = goal.id else { return }
        
        do {
            try await db.collection("goals").document(id).delete()
            // Remove the goal from local array instead of fetching
            goals.removeAll { $0.id == id }
        } catch {
            errorMessage = "failed to delete goal: \(error.localizedDescription)"
        }
    }
}


    
   
