
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth


class UserService: ObservableObject {
    // Published user for observing current user changes
    @Published var currentUser: User?

    // Shared singleton instance
    static let shared = UserService()

    // Private initializer so only one instance is used
    private init() {
        Task {
            try? await fetchCurrentUser()
        }
    }

    // Fetch and set the current logged-in user
    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        self.currentUser = try snapshot.data(as: User.self)
    }

    // Static method to fetch all users from Firestore
    static func fetchAllUsers() async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }

    static func fetchUser(withUid uid: String, completion: @escaping (User) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            completion(user)
        }
    }
}
