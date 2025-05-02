import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct MessageService {
    static let messagesCollection = Firestore.firestore().collection("messages")
    
    static func sendMessage(_ messageText: String, toUser user: User) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = user.id
        
        let currentUserRef = messagesCollection.document(currentUid).collection(chatPartnerId).document()
        let chatPartnerRef = messagesCollection.document(chatPartnerId).collection(currentUid)
        
        let recentCurrentUserRef = messagesCollection.document(currentUid).collection("recent-messages").document(chatPartnerId)
        let recentPartnerRef = messagesCollection.document(chatPartnerId).collection("recent-messages").document(currentUid)
        
        let messageId = currentUserRef.documentID
        
        let message = Message(
            messageId: messageId,
            fromId: currentUid,
            toId: chatPartnerId,
            messageText: messageText,
            timestamp: Timestamp(date: Date())
        )
        
        guard let messageData = try? Firestore.Encoder().encode(message) else { return }
        
        currentUserRef.setData(messageData)
        chatPartnerRef.document(messageId).setData(messageData)
        
        recentCurrentUserRef.setData(messageData)
        recentPartnerRef.setData(messageData)

    }
    
    static func observeMessages(chatPartner: User, completion: @escaping([Message]) -> Void) { //looks for the messages being sent
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let chatPartnerId = chatPartner.id
        
        //querying the messages section of the database
        let query = messagesCollection
            .document(currentUid)
            .collection(chatPartnerId)
            .order(by: "timestamp", descending: false)
        
        // listens for events or when things get added to the database
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added}) else { return } //allows the firebase to show instant updates, allowing for real time messages (only focuses on the added doc change type)
            var messages = changes.compactMap({ try? $0.document.data(as: Message.self)}) // decode the incoming data, brings the data back from the document changes and maps it the messages
            
            
            //this for loop is used to set the user object on each individual message, only if the message is not from the current user
            for (index, message) in messages.enumerated() where !message.isFromCurrentUser {
                messages[index].user = chatPartner
            }
            
            completion(messages) //completion handler is called, which is stated in the parameters above which how the messages is taken to the chatViewModel
        }
        
    }
    
}
