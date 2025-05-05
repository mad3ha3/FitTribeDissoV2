
import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

//view model for the leaderboard screen based on their gym attendance count
@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var users: [LeaderboardUser] = []  //sorted list of users for the leaderboard
    @Published var errorMessage: String?  //error message for ui feedback
    @Published var isLoading = false //ui loading state
    @Published var followedUserIds: [String] = []
    
    private let db = Firestore.firestore()
    private let gymAttendanceViewModel = GymAttendanceViewModel()  //used to count check in per user
    
    init() { // leaderboard data is fetched after initialisation
        Task {
            await fetchFollowedUserIds()
            await fetchLeaderboard()
        }
    }
    
    func fetchLeaderboard(showFriendsOnly: Bool = false) async {
        isLoading = true
       
        
        do {
            
            // First, get all users
            let usersSnapshot = try await db.collection("users").getDocuments() //fetches all registered users from firestore
            
            
            if usersSnapshot.documents.isEmpty {
                print("DEBUG: WARNING - No users found in the database")
            }
            
            var leaderboardUsers: [LeaderboardUser] = []
            let currentUserId = Auth.auth().currentUser?.uid
            
            for document in usersSnapshot.documents {
                let userId = document.documentID
                
                // Skip users not in followed list if showing friends only, unless it's the current user
                if showFriendsOnly && !followedUserIds.contains(userId) && userId != currentUserId {
                    continue
                }
                
            
                
                let attendanceCount = await gymAttendanceViewModel.getAttendanceCount(for: userId) //count attendance entries for each user
                
                
                do {
                    let user = try document.data(as: User.self)
                    
                    //add user to leaderboard
                    leaderboardUsers.append(LeaderboardUser(
                        id: userId,
                        fullname: user.fullname,
                        points: attendanceCount  //the attendance count is the points for the leaderboard
                    ))
                } catch {
                    
                    print("DEBUG: Error details: \(error)")
                    
                }
            }
            
            // users are sorted by descending order
            self.users = leaderboardUsers.sorted { $0.points > $1.points }
            
            isLoading = false
        } catch {
            
            errorMessage = "Failed to fetch leaderboard"
            isLoading = false
        }
    }
    
    func fetchFollowedUserIds() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        do {
            let snapshot = try await db.collection("users")
                .document(currentUserId)
                .collection("following")
                .getDocuments()
            
            let ids = snapshot.documents.map { $0.documentID }
            self.followedUserIds = ids
        } catch {
            print("DEBUG: Failed to fetch followed user IDs: \(error.localizedDescription)")
        }
    }
}

    
