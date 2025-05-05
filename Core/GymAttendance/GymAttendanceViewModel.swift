import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

@MainActor
class GymAttendanceViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var hasCheckedInToday = false
    
    private let db = Firestore.firestore()
    
    init() {
        Task {
            await checkIfUserHasCheckedInToday()
        }
    }
    
    func checkIfUserHasCheckedInToday() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user ID found")
            return
        }
        
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
            
            hasCheckedInToday = !todayRecords.isEmpty
        } catch {
            print("DEBUG: Error checking attendance: \(error.localizedDescription)")
            errorMessage = "Failed to check attendance status"
        }
    }
    
    func checkIn() async -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        guard !hasCheckedInToday else { return false }
        
        isLoading = true
        
        do {
            let attendance = GymAttendance(
                userId: userId,
                timestamp: Date()
            )
            
            try db.collection("gymAttendance").addDocument(from: attendance)
            hasCheckedInToday = true
            isLoading = false
            return true
        } catch {
            print("DEBUG: Error checking in: \(error.localizedDescription)")
            errorMessage = "Failed to check in"
            isLoading = false
            return false
        }
    }
    
    func getAttendanceCount(for userId: String) async -> Int {
        print("DEBUG: Getting attendance count for user: \(userId)")
        do {
            let snapshot = try await db.collection("gymAttendance") //counts attendance records for a specific user
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            print("DEBUG: Found \(snapshot.documents.count) attendance records for user \(userId)")
            return snapshot.documents.count //returns the total count as points for the leaderboard
        } catch {
            print("DEBUG: ERROR - Failed to get attendance count for user \(userId): \(error.localizedDescription)")
            print("DEBUG: Error details: \(error)")
            return 0
        }
    }
} 