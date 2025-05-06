import SwiftUI

// shows the currentuser's chat inbox with recent messages and new chat button
struct InboxView: View {
    @State private var showNewMessageView = false // controls showing new message screen
    @StateObject private var viewModel = InboxViewModel() 
    @State private var selectedUser: User? // user selected for chat
    @State private var showChat = false 
    
    // the current user from view model
    private var user: User? {
        return viewModel.currentUser
    }
    
    var body: some View {
        NavigationStack {
            messageList // list of recent messages
                .onChange(of: selectedUser) { oldValue, newValue in
                    showChat = newValue != nil // open chat if a user is selected
                }
                .onChange(of: showChat) { oldValue, newValue in
                    if !newValue {
                        selectedUser = nil  // Reset selectedUser when chat is dismissed
                    }
                }
                // open chat view if a user chat is selected
                .navigationDestination(isPresented: $showChat) {
                    if let selectedUser = selectedUser {
                        ChatView(user: selectedUser)
                    }
                }
                // open new message view as a full screen cover
                .fullScreenCover(isPresented: $showNewMessageView) {
                    NewMessageView(selectedUser: $selectedUser)
                }
                .navigationTitle("Chats")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
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
    
    // list of recent messages with swipe to delete functionality
    private var messageList: some View {
        List {
            ForEach(viewModel.recentMessages) { message in
                messageRow(message: message)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) { // this is the action for the swipe to delete
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteChat(message: message) 
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // one row for each message which opens on tap
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
