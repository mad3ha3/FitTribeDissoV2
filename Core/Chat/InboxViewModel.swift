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
}
