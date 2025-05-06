import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// handles sending and receiving chat messages using Firestore
struct MessageService {
    static let messagesCollection = Firestore.firestore().collection("messages")
    
    // sends a message to another user and updates both users' message collections
    static func sendMessage(_ messageText: String, toUser user: User) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = user.id
        
        // references for current user and chat partner message collections
        let currentUserRef = messagesCollection.document(currentUid).collection(chatPartnerId).document()
        let chatPartnerRef = messagesCollection.document(chatPartnerId).collection(currentUid)
        
        // references for recent messages for inbox view
        let recentCurrentUserRef = messagesCollection.document(currentUid).collection("recent-messages").document(chatPartnerId)
        let recentPartnerRef = messagesCollection.document(chatPartnerId).collection("recent-messages").document(currentUid)
        
        let messageId = currentUserRef.documentID
        
        // message object created with this
        let message = Message(
            messageId: messageId,
            fromId: currentUid,
            toId: chatPartnerId,
            messageText: messageText,
            timestamp: Timestamp(date: Date())
        )
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        // save message for both users
        currentUserRef.setData(messageData)
        chatPartnerRef.document(messageId).setData(messageData)
        
        // update recent messages for both users
        recentCurrentUserRef.setData(messageData)
        recentPartnerRef.setData(messageData)
    }
    
    // listens for new messages in a chat and returns them, real time func
    static func observeMessages(chatPartner: User, completion: @escaping([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        
        let query = messagesCollection
            .document(currentUid)
            .collection(chatPartnerId)
            .order(by: "timestamp", descending: false)
        
        // listens for events or when things get added to the database
        query.addSnapshotListener { snapshot, _ in
            // process added messages
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added}) else { return }
            var messages = changes.compactMap({ try? $0.document.data(as: Message.self)})
            
            
            //this for loop is used to set the user object on each individual message, only if the message is not from the current user
            for (index, message) in messages.enumerated() where !message.isFromCurrentUser {
                messages[index].user = chatPartner
            }
            
            completion(messages) //completion handler is called, which is stated in the parameters above which how the messages is taken to the chatViewModel
        }
        
    }
}
