import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = [] //list of users workouts
    @Published var workoutTypes: [String] = [] //list of users wokrout types
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var hasInitialFetch = false
    
    init() {
        Task {
            await initialFetch()
        }
    }
    
    //prevents multiple fetches, load workouts and workout types
    private func initialFetch() async {
        if hasInitialFetch { return }
        hasInitialFetch = true
        await fetchWorkouts()
        await fetchWorkoutTypes()
    }
    
    //refreshes workoutlist
    func refreshWorkouts() async {
        await fetchWorkouts()
    }
    
    //fetches all workouts of the current user
    private func fetchWorkouts() async {
        guard !isLoading, let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            let snapshot = try await db.collection("workouts")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            self.workouts = snapshot.documents.compactMap { document in
                try? document.data(as: Workout.self)
            }
            // Sort the workouts by date after fetching
            self.workouts.sort { $0.date > $1.date }
        } catch {
            print("DEBUG: Error fetching workouts: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch workouts: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    //fetches all workouts types for the current user
    private func fetchWorkoutTypes() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workoutTypes")
                .getDocuments()
            
            self.workoutTypes = snapshot.documents.compactMap { document in
                document.data()["name"] as? String
            }
            self.workoutTypes.sort()

        } catch {
            print("DEBUG: Error fetching workout types: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch workout types: \(error.localizedDescription)"
        }
    }
    
    //add workout entry to firebase for the current user
    func addWorkout(workout: Workout) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var workoutToAdd = workout
        workoutToAdd.userId = userId
        
        do {
            let docRef = try db.collection("workouts").addDocument(from: workoutToAdd)
            await refreshWorkouts()
        } catch {
            print("DEBUG: Error adding workout: \(error.localizedDescription)")
            self.errorMessage = "Failed to add workout: \(error.localizedDescription)"
        }
    }
    
    //add workout type to firebase for the current user
    func addWorkoutType(type: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Check if the type already exists
        if workoutTypes.contains(type) {
            return
        }
        
        do {
            // Add the workout type to the user's collection
            try await db.collection("users")
                .document(userId)
                .collection("workoutTypes")
                .addDocument(data: [
                    "name": type,
                    "createdAt": Timestamp()
                ])
            
            // Update local state
            workoutTypes.append(type)
            workoutTypes.sort()
            print("DEBUG: Added workout type: \(type)")
        } catch {
            print("DEBUG: Error adding workout type: \(error.localizedDescription)")
            self.errorMessage = "Failed to add workout type: \(error.localizedDescription)"
        }
    }
    
    //deletes workout from firestore
    func deleteWorkout(workout: Workout) async {
        guard let id = workout.id else { return }
        
        do {
            try await db.collection("workouts").document(id).delete()
            // Remove the workout from local array instead of fetching
            workouts.removeAll { $0.id == id }
        } catch {
            print("DEBUG: Error deleting workout: \(error.localizedDescription)")
            self.errorMessage = "Failed to delete workout: \(error.localizedDescription)"
        }
    }
    
    //deletes workout type from firestore
    func deleteWorkoutType(type: String) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Get the document reference for this workout type
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workoutTypes")
                .whereField("name", isEqualTo: type)
                .getDocuments()
            
            // Delete the document if found
            if let document = snapshot.documents.first {
                try await document.reference.delete()
            // Update local state
            workoutTypes.removeAll { $0 == type }
            print("DEBUG: Deleted workout type: \(type)")
            }
        } catch {
            print("DEBUG: Error deleting workout type: \(error.localizedDescription)")
            self.errorMessage = "Failed to delete workout type: \(error.localizedDescription)"
        }
    }
}
