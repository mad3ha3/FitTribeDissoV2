import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore

// logic for the chat inbox, including recent messages and deleting chats
class InboxViewModel: ObservableObject {
    @Published var currentUser: User? // current user
    @Published var recentMessages = [Message]() // list of recent chat messages
    private var documentChanges: [DocumentChange] = [] // tracks the chat changes 
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    init() {
        setupSubscribers()
        observeRecentMessages()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
    }
    
    // changes in recent messages are observed
    private func observeRecentMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("messages")
            .document(uid)
            .collection("recent-messages")
            .order(by: "timestamp", descending: true)

        query.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self,
                  let changes = snapshot?.documentChanges.filter({ 
                    $0.type == .added || $0.type == .modified
                  }) else { return }
            
            self.documentChanges = changes
            self.loadInitialMessages(fromChanges: changes)
        }
    }
    
    // loads and updates the recent messages list
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        var messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
        
        // Remove any old existing messages with the same chatPartnerId
        for message in messages {
            recentMessages.removeAll { $0.chatPartnerId == message.chatPartnerId }
        }

        // fetch user info for each message and updates the list
        for i in 0 ..< messages.count {
            let message = messages[i]
            
            UserService.fetchUser(withUid: message.chatPartnerId) { [weak self] user in
                guard let self = self else { return }
                messages[i].user = user
                self.recentMessages.append(messages[i])
            }
        }
    }
    
    // deletes chat for current user
    @MainActor
    func deleteChat(message: Message) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Delete current user's recent message
            try await db.collection("messages")
                .document(uid)
                .collection("recent-messages")
                .document(message.chatPartnerId)
                .delete()
            
            // Delete current user's copy of messages
            let messagesSnapshot = try await db.collection("messages")
                .document(uid)
                .collection(message.chatPartnerId)
                .getDocuments()
            
            for doc in messagesSnapshot.documents {
                try await doc.reference.delete()
            }
            
            // Update local state
            self.recentMessages.removeAll { $0.chatPartnerId == message.chatPartnerId }
            
        } catch {
            print("DEBUG: Failed to delete chat: \(error.localizedDescription)")
        }
    }
}
