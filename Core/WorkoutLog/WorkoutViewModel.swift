import Foundation
 import FirebaseFirestore
 import FirebaseAuth
 
 @MainActor
 class WorkoutViewModel: ObservableObject {
     @Published var workouts: [Workout] = []
     @Published var errorMessage: String?
     @Published var isLoading = false
     
     private let db = Firestore.firestore()
     private var hasInitialFetch = false
     
     init() {
         Task {
             await initialFetch()
         }
     }
     
     private func initialFetch() async {
         guard !hasInitialFetch else { return }
         hasInitialFetch = true
         await fetchWorkouts()
     }
     
     func refreshWorkouts() async {
         await fetchWorkouts()
     }
     
     private func fetchWorkouts() async {
         guard !isLoading else { return }
         isLoading = true
         
         guard let userId = Auth.auth().currentUser?.uid else {
             print("DEBUG: No user ID found")
             isLoading = false
             return
         }
         
         do {
             let snapshot = try await db.collection("workouts")
                 .whereField("userId", isEqualTo: userId)
                 .getDocuments()
             
             self.workouts = snapshot.documents.compactMap { document in
                 try? document.data(as: Workout.self)
             }
             // Sort the workouts by date after fetching
             self.workouts.sort { $0.date > $1.date }
             print("DEBUG: Fetched \(self.workouts.count) workouts")
         } catch {
             print("DEBUG: Error fetching workouts: \(error.localizedDescription)")
             self.errorMessage = "Failed to fetch workouts: \(error.localizedDescription)"
         }
         
         isLoading = false
     }
     
     func addWorkout(_ workout: Workout) async {
         guard let userId = Auth.auth().currentUser?.uid else {
             print("DEBUG: No user ID found when adding workout")
             return
         }
         
         var workoutToAdd = workout
         workoutToAdd.userId = userId
         
         do {
             let docRef = try db.collection("workouts").addDocument(from: workoutToAdd)
             print("DEBUG: Added workout with ID: \(docRef.documentID)")
             await refreshWorkouts() // Use refresh instead of fetch
         } catch {
             print("DEBUG: Error adding workout: \(error.localizedDescription)")
             self.errorMessage = "Failed to add workout: \(error.localizedDescription)"
         }
     }
 }
