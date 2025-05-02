import Foundation
import FirebaseFirestore

@MainActor
class FollowViewModel: ObservableObject {
    @Published var isFollowed: Bool = false
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let db = Firestore.firestore()

    // Check if currentUser is following targetUser
    func checkFollowStatus(currentUserId: String, targetUserId: String) async {
        isLoading = true
        errorMessage = nil
        
        let docRef = db.collection("users")
            .document(currentUserId)
            .collection("following")
            .document(targetUserId)

        do {
            let doc = try await docRef.getDocument()
            self.isFollowed = doc.exists
            await fetchFollowCounts(for: targetUserId)
        } catch {
            print("Error checking follow status: \(error.localizedDescription)")
            errorMessage = "Failed to check follow status"
        }
        
        isLoading = false
    }

    // Follow targetUser
    func follow(userId: String, currentUserId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Add to following
            try await db.collection("users")
                .document(currentUserId)
                .collection("following")
                .document(userId).setData([:])

            // Add to followers
            try await db.collection("users")
                .document(userId)
                .collection("followers")
                .document(currentUserId).setData([:])

            isFollowed = true
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
            // Remove from following
            try await db.collection("users")
                .document(currentUserId)
                .collection("following")
                .document(userId).delete()

            // Remove from followers
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
            let followersSnap = try await db.collection("users")
                .document(userId)
                .collection("followers").getDocuments()

            let followingSnap = try await db.collection("users")
                .document(userId)
                .collection("following").getDocuments()

            followersCount = followersSnap.documents.count
            followingCount = followingSnap.documents.count
        } catch {
            print("Error fetching follow counts: \(error.localizedDescription)")
            errorMessage = "Failed to fetch follow counts"
        }
    }
}

