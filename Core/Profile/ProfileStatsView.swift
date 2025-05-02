import SwiftUI

struct ProfileStatsView: View {
    let followers: Int
    let following: Int
    var points: Int? = nil

    var body: some View {
        HStack(spacing: 32) {
            VStack {
                Text("\(followers)")
                    .font(.headline)
                Text("Followers")
                    .font(.caption)
            }

            VStack {
                Text("\(following)")
                    .font(.headline)
                Text("Following")
                    .font(.caption)
            }

            if let points = points {
                VStack {
                    Text("🔥\(points)")
                        .font(.headline)
                    Text("Points")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    ProfileStatsView(followers: 120, following: 85, points: 550)
}
