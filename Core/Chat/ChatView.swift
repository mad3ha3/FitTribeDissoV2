import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    let user: User
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            ScrollView{
                //header
                VStack(spacing: 4){
                    Text(user.fullname)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("messenger")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                //messages
                ForEach(viewModel.messages) { message in
                    ChatMessageCell(message: message)
                }
            }
            
            //message input view
            Spacer()
            ZStack(alignment: .trailing){
                TextField("Message.. ", text: $viewModel.messageText, axis: .vertical)
                    .padding(12)
                    .padding(.trailing, 48)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(Capsule())
                    .font(.subheadline)
                
                Button{
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
