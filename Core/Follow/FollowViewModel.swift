import Foundation
import FirebaseFirestore

@MainActor //need to publish all UI updates on the main thread
class FollowViewModel: ObservableObject { //observable allows view to see changes
    @Published var isFollowed: Bool = false //if the current user follows the searched user
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var errorMessage: String? //error message
    @Published var isLoading = false

    //ref to fb instance
    private let db = Firestore.firestore()

    // Check if currentUser is following targetUser
    func checkFollowStatus(currentUserId: String, targetUserId: String) async {
        isLoading = true //starts the loading state
        errorMessage = nil
        
        //ref to doc which shows if current user follows searched user
        let docRef = db.collection("users")
            .document(currentUserId)
            .collection("following")
            .document(targetUserId)

        do {
            let doc = try await docRef.getDocument() //goes to fetch document
            self.isFollowed = doc.exists //this is set based on whether the docuemnt exists
            await fetchFollowCounts(for: targetUserId) //follower/following counts are fetched
        } catch { //error messages
            print("Error checking follow status: \(error.localizedDescription)")
            errorMessage = "Failed to check follow status"
        }
        
        isLoading = false //ends loading state
    }

    // Follow targetUser
    func follow(userId: String, currentUserId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Add to current users following
            try await db.collection("users")
                .document(currentUserId)
                .collection("following")
                .document(userId).setData([:])

            // Adds the current user to the search user's followers
            try await db.collection("users")
                .document(userId)
                .collection("followers")
                .document(currentUserId).setData([:])

            isFollowed = true //upddates follow
            await fetchFollowCounts(for: userId)
        } catch {
            print("Error following user: \(error.localizedDescription)")
            errorMessage = "Failed to follow user"
        }
        
        isLoading = false
    }

    // Unfollow targetUser
    func unfollow(userId: String, currentUserId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Remove searched user from current users following
            try await db.collection("users")
                .document(currentUserId)
                .collection("following")
                .document(userId).delete()

            // Removes current user from searched users followers
            try await db.collection("users")
                .document(userId)
                .collection("followers")
                .document(currentUserId).delete()

            isFollowed = false
            await fetchFollowCounts(for: userId)
        } catch {
            print("Error unfollowing user: \(error.localizedDescription)")
            errorMessage = "Failed to unfollow user"
        }
        
        isLoading = false
    }

    // Get followers/following count for any user
    func fetchFollowCounts(for userId: String) async {
        do {
            //this gets the list of docs in the users followers collection from the db
            let followersSnap = try await db.collection("users")
                .document(userId)
                .collection("followers").getDocuments()

            //this gets the list of docs in the users following collection
            let followingSnap = try await db.collection("users")
                .document(userId)
                .collection("following").getDocuments()

            //gets the numbers for each by counting doc
            followersCount = followersSnap.documents.count
            followingCount = followingSnap.documents.count
        } catch {
            print("Error fetching follow counts: \(error.localizedDescription)")
            errorMessage = "Failed to fetch follow counts"
        }
    }
}

