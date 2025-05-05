

import SwiftUI

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
    LeaderboardRow(user: .init(id: "1", fullname: "test", points: 1000), rank: 1)
}

