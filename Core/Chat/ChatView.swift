import SwiftUI

// chat screen for messaging a current user
struct ChatView: View {
    @StateObject var viewModel: ChatViewModel // deals with chat logic and state
    let user: User // the user being spoken with
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user)) 
    }
    
    var body: some View {
        VStack {
            ScrollView {
                //header titles
                VStack(spacing: 4){
                    Text(user.fullname)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("messages")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                //list of messages uses the chat message cell view
                ForEach(viewModel.messages) { message in
                    ChatMessageCell(message: message)
                }
            }
            
            
            Spacer()
            ZStack(alignment: .trailing){
                TextField("Message.. ", text: $viewModel.messageText, axis: .vertical) //messaage input field
                    .padding(12)
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(Capsule())
                    .font(.subheadline)
                
                Button{ // send message button
                    viewModel.sendMessage() 
                    viewModel.messageText = "" 
                } label: {
                    Text("send")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    ChatView(user: User.MOCK_USER)
}
