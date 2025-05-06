import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class GymAttendanceViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var hasCheckedInToday = false //tracks whther the user has checked in
    
    private let db = Firestore.firestore()
    
    init() {
        Task {
            await checkIfUserHasCheckedInToday() //check if user has already check in to the gym
        }
    }
    
    //checks for a check in for today
    func checkIfUserHasCheckedInToday() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Get all attendance records for the user
            let snapshot = try await db.collection("gymAttendance")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            // Filter in memory for today's records
            let today = Calendar.current.startOfDay(for: Date())
            let todayRecords = snapshot.documents.filter { document in
                if let timestamp = document.data()["timestamp"] as? Timestamp {
                    let date = timestamp.dateValue()
                    return Calendar.current.isDate(date, inSameDayAs: today)
                }
                return false
            }
            hasCheckedInToday = !todayRecords.isEmpty //if there is a doc match the current user has already checked in today
        } catch {
            print("DEBUG: Error checking attendance: \(error.localizedDescription)")
            errorMessage = "Failed to check attendance status"
        }
    }
    
    //check in if current user has not checked in today
    func checkIn() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        guard !hasCheckedInToday else { return false }
        
        isLoading = true
        
        do {
            //attedance record is created here
            let attendance = GymAttendance(
                userId: userId,
                timestamp: Date()
            )
            
            try db.collection("gymAttendance").addDocument(from: attendance)
            hasCheckedInToday = true //this updates the state
            isLoading = false
            return true
        } catch {
            print("DEBUG: Error checking in: \(error.localizedDescription)")
            errorMessage = "Failed to check in"
            isLoading = false
            return false
        }
    }
    
    // counts the number of check ins for each user
    func getAttendanceCount(for userId: String) async -> Int {
        do {
            let snapshot = try await db.collection("gymAttendance") //counts attendance records for a specific user
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            return snapshot.documents.count //returns the total count as points for the leaderboard
        } catch {
            print("DEBUG: ERROR - Failed to get attendance count for user \(userId): \(error.localizedDescription)")
            return 0
        }
    }
} 
