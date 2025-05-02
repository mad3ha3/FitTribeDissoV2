import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

//this model is used for messaging between users
struct Message: Identifiable, Codable {
    @DocumentID var messageId: String? //unique identifier set up by Firebase for the message
    let fromId: String //id of the sender
    let toId: String //id of the reciever
    let messageText: String //the content of the message
    let timestamp: Timestamp //timestape of when the message was sent
    var isRead: Bool = false //whether the message was read or not

    var user: User?
    
    //unique identifier for the message
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
    //returns the id of the other perons in the conversation
    var chatPartnerId: String {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    //is true if the message was sent by the user that is currently signed in
    var isFromCurrentUser: Bool {
        return fromId == Auth.auth().currentUser?.uid
    }
}
