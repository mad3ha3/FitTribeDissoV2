//
//  UserProfileView.swift
//  disso
//
//  Created by Madeha Ahmed on 22/04/2025.
//
import SwiftUI


struct UserProfileView: View {
    let user: User
    @StateObject private var followViewModel = FollowViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileHeaderView(user: user)

                ProfileStatsView(
                    followers: followViewModel.followersCount,
                    following: followViewModel.followingCount
                )

                Button(action: {
                    Task {
                        if followViewModel.isFollowed {
                            await followViewModel.unfollow(userId: user.id, currentUserId: authViewModel.currentUser?.id ?? "")
                        } else {
                            await followViewModel.follow(userId: user.id, currentUserId: authViewModel.currentUser?.id ?? "")
                        }
                    }
                }) {
                    Text(followViewModel.isFollowed ? "Unfollow" : "Follow")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(followViewModel.isFollowed ? Color.gray : Color("AppOrange"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Divider()
            }
            .padding()
            .navigationTitle(user.fullname)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                if let currentId = authViewModel.currentUser?.id {
                    await followViewModel.checkFollowStatus(currentUserId: currentId, targetUserId: user.id)
                    await followViewModel.fetchFollowCounts(for: user.id)
                }
            }
        }
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    authViewModel.currentUser = User.MOCK_USER
    
    return NavigationStack {
        UserProfileView(user: User.MOCK_USER)
            .environmentObject(authViewModel)
    }
}

