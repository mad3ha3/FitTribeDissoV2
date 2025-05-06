//
//  AchievementView.swift
//  disso
//
//  Created by Madeha Ahmed on 06/05/2025.
//

import SwiftUI

struct AchievementView: View {
    @StateObject private var leaderboardViewModel = LeaderboardViewModel() //called because access to userPoints is needed and used for the points the user has
    
    // Helper func to get each achievement label
    private func achievementLevel(for points: Int) -> String {
        switch points {
        case 50...: return "Champion"
        case 40..<50: return "Top Performer"
        case 30..<40: return "Achiever"
        case 20..<30: return "Challenger"
        case 10..<20: return "Dedicated"
        case 1..<10: return "Newbie"
        default: return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Your Gym Achievements!")
                .font(.title)
                .fontWeight(.bold)
            
            if leaderboardViewModel.userPoint == 0 { //this text is displayed when the user has no points
                Text("Log your gym attendance to start earning points and unlock achievements!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Points: \(leaderboardViewModel.userPoint)") // points the user has
                    .font(.title2) 
                    .padding(.bottom, 8)
                
                Text("Level: \(achievementLevel(for: leaderboardViewModel.userPoint))") // different acheievemnt levels based on the points, uses the helper func to get the levels
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(Color("AppOrange"))
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AchievementView()
}
