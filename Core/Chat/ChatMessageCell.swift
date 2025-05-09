import SwiftUI

//this is going to determine where the message is going to go and how it will look
struct ChatMessageCell: View {
    let message: Message // message data
    
    // checks if the message is from the current user
    private var isFromCurrentUser: Bool {
        return message.isFromCurrentUser
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer() // this pushes the message to the right
                
                Text(message.messageText)
                    .font(.subheadline)
                    .padding()
                    .background(Color(.systemTeal)) // teal bubble for current user
                    .foregroundColor(.white)
                    .clipShape(ChatBubble(isFromCurrentUser: isFromCurrentUser))
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
            } else {
                // message from other user and bubble on left
                HStack(alignment: .bottom, spacing: 4){
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)

                    Text(message.messageText)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray5)) // gray bubble for message for chat partner
                        .foregroundColor(.black)
                        .clipShape(ChatBubble(isFromCurrentUser: isFromCurrentUser))
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

/*#Preview {
    ChatMessageCell(isFromCurrentUser: false)
}*/
