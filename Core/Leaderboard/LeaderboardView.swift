
import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @State private var selectedTab = 0 //too track each tab gloabl and friends
    @State private var leaderboardLoad = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented toggle for Global/Friends
                Picker("Leaderboard Type", selection: $selectedTab) {
                    Text("Global").tag(0)
                    Text("Friends").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedTab) { oldValue, newValue in
                    Task { //fetches the selected leaderboard
                        await viewModel.fetchFollowedUserIds()
                        await viewModel.fetchLeaderboard(showFriendsOnly: newValue == 1)
                    }
                }
                
                List {
                    ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in //goes through each user and displays them in a row each
                        LeaderboardRow(user: user, rank: index + 1)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .overlay {
                    // Leaderboard Content
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.users.isEmpty {
                        VStack {
                            Spacer()
                            Text(selectedTab == 0 ? "No users found" : "No friends found")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                }
            .navigationTitle("Leaderboard")
            .refreshable {
                if viewModel.isLoading {//pull the leaderbaord to referesh the points
                    await viewModel.fetchFollowedUserIds()
                    await viewModel.fetchLeaderboard(showFriendsOnly: selectedTab == 1)
                }
            }
        }
        .onAppear {
            if !leaderboardLoad {
                leaderboardLoad = true
                Task {
                    await viewModel.fetchFollowedUserIds()
                    await viewModel.fetchLeaderboard(showFriendsOnly: selectedTab == 1)
                }
            }
        }
    }
}


#Preview {
    LeaderboardView()
}
