import SwiftUI

struct InboxView: View {
    @State private var showNewMessageView = false
    @StateObject private var viewModel = InboxViewModel()
    @State private var selectedUser: User?
    @State private var showChat = false
    
    private var user: User? {
        return viewModel.currentUser
    }
    
    var body: some View {
        NavigationStack {
            messageList
                .onChange(of: selectedUser) { oldValue, newValue in
                    showChat = newValue != nil
                }
                .navigationDestination(isPresented: $showChat) {
                    if let selectedUser = selectedUser {
                        ChatView(user: selectedUser)
                    }
                }
                .fullScreenCover(isPresented: $showNewMessageView) {
                    NewMessageView(selectedUser: $selectedUser)
                }
                .navigationBarTitle("", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("Chats")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showNewMessageView.toggle()
                            selectedUser = nil
                        } label: {
                            Image(systemName: "square.and.pencil.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.black, Color(.systemGray))
                        }
                    }
                }
        }
    }
    
    private var messageList: some View {
        List {
            ForEach(viewModel.recentMessages) { message in
                messageRow(message: message)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private func messageRow(message: Message) -> some View {
        InboxRowView(message: message)
            .onTapGesture {
                selectedUser = message.user
            }
    }
}

#Preview {
    InboxView()
}
