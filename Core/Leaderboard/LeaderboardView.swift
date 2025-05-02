
import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control for Global/Friends
                Picker("Leaderboard Type", selection: $selectedTab) {
                    Text("Global").tag(0)
                    Text("Friends").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedTab) { oldValue, newValue in
                    Task {
                        await viewModel.fetchLeaderboard(showFriendsOnly: newValue == 1)
                    }
                }
                
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
                } else {
                    List {
                        ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                            LeaderboardRow(user: user, rank: index + 1)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Leaderboard")
            .refreshable {
                await viewModel.fetchLeaderboard(showFriendsOnly: selectedTab == 1)
            }
        }
    }
}

struct LeaderboardRow: View {
    let user: LeaderboardUser
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            Text("\(rank)")
                .font(.system(size: 17, weight: .bold))
                .frame(width: 32, height: 32)
                .background(Circle().fill(rankColor))
                .foregroundColor(.white)
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullname)
                    .font(.headline)
                Text("\(user.points) \(user.points == 1 ? "point" : "points")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Trophy Icon for Top 3
            if rank <= 3 {
                Image(systemName: rank == 1 ? "trophy.fill" : "medal.fill")
                    .foregroundColor(rank == 1 ? .yellow : rank == 2 ? .gray : .brown)
                    .imageScale(.large)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
}

#Preview {
    LeaderboardView()
}
