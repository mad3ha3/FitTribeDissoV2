import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestore

class InboxViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var recentMessages = [Message]()
    private var documentChanges: [DocumentChange] = []
    
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
    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        var messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
        
        // Remove any existing messages with the same chatPartnerId
        for message in messages {
            recentMessages.removeAll { $0.chatPartnerId == message.chatPartnerId }
        }

        for i in 0 ..< messages.count {
            let message = messages[i]
            
            UserService.fetchUser(withUid: message.chatPartnerId) { [weak self] user in
                guard let self = self else { return }
                messages[i].user = user
                self.recentMessages.append(messages[i])
            }
        }
    }
    
    @MainActor
    func deleteChat(message: Message) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Delete recent message for current user
            try await db.collection("messages")
                .document(uid)
                .collection("recent-messages")
                .document(message.chatPartnerId)
                .delete()
            
            // Delete recent message for chat partner
            try await db.collection("messages")
                .document(message.chatPartnerId)
                .collection("recent-messages")
                .document(uid)
                .delete()
            
            // Delete all messages in the chat
            let messagesSnapshot = try await db.collection("messages")
                .document(uid)
                .collection(message.chatPartnerId)
                .getDocuments()
            
            for doc in messagesSnapshot.documents {
                try await doc.reference.delete()
            }
            
            // Delete partner's copy of messages
            let partnerMessagesSnapshot = try await db.collection("messages")
                .document(message.chatPartnerId)
                .collection(uid)
                .getDocuments()
            
            for doc in partnerMessagesSnapshot.documents {
                try await doc.reference.delete()
            }
            
            // Update local state
            await MainActor.run {
                self.recentMessages.removeAll { $0.chatPartnerId == message.chatPartnerId }
            }
            
        } catch {
            print("DEBUG: Failed to delete chat: \(error.localizedDescription)")
        }
    }
}
