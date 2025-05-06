import Foundation

// chat logic for a single conversation
class ChatViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages = [Message]()
    let user: User
   
    init(user: User) {
        self.user = user
        observeMessages()
    }
    
    // listens for new messages from the chat partner
    func observeMessages() {
        MessageService.observeMessages(chatPartner: user) { messages in
            self.messages.append(contentsOf: messages)
        }
    }
    
    // sends a new message to the chat partner
    func sendMessage() {
        MessageService.sendMessage(messageText, toUser: user)
    }
}
