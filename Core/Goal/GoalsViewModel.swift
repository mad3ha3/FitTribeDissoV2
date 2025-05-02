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
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            let snapshot = try await db.collection("goals")
                .whereField("userID", isEqualTo: userId)
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            self.goals = snapshot.documents.compactMap { doc in
                try? doc.data(as: Goal.self)
            }
            } catch {
                errorMessage = "failed to load goals: \(error.localizedDescription)"
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
            let ref = try db.collection( "goals" ).addDocument(from: newGoal)
            
            await fetchGoals()
        } catch {
            errorMessage = "failed to add goal: \(error.localizedDescription)"
        }
    }
    
    func toggleCompletedGoal( _ goal: Goal) async {
        guard let id = goal.id else { return }
        
        var updatedGoal = goal
        updatedGoal.isDone.toggle()
        
        do {
            try db.collection("goals").document(id).setData(from: updatedGoal)
            await fetchGoals()
        } catch {
            errorMessage = "failed to toggle goal: \(error.localizedDescription)"
        }
    }
    
    func deleteGoal(_ goal: Goal) async {
        guard let id = goal.id else { return }
        
        do {
            try await db.collection( "goals" ).document(id).delete()
            await fetchGoals()
        } catch {
            errorMessage = "failed to delete goal: \(error.localizedDescription)"
        }
    }
}


    
   
