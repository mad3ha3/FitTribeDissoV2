import Foundation
import Firebase
import FirebaseAuth

// logic for displaying users to start a new chat
@MainActor
class NewMessageViewModel: ObservableObject {
    @Published var users = [User]() // list of users

    init() {
        Task { try await fetchUsers() }
    }
    
    // fetches all users except the current user
    func fetchUsers() async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let users = try await UserService.fetchAllUsers()
        self.users = users.filter { $0.id != currentUid }
    }
}
