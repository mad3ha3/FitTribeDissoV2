//
//  AchievementView.swift
//  disso
//
//  Created by Madeha Ahmed on 06/05/2025.
//

import SwiftUI

struct AchievementView: View {
    @StateObject private var leaderboardViewModel = LeaderboardViewModel()
    
    // Helper to get each achievement label
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
            Text("Gym Achievements !")
                .font(.title)
                .fontWeight(.bold)
            
            if leaderboardViewModel.userPoint == 0 {
                Text("Log your gym attendance to start earning points and unlock achievements!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Points: \(leaderboardViewModel.userPoint)")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.bottom, 8)
                
                Text("Level: \(achievementLevel(for: leaderboardViewModel.userPoint))")
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
