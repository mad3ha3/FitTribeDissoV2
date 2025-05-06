import SwiftUI

//used to display the following and followers
struct ProfileStatsView: View {
    let followers: Int
    let following: Int

    var body: some View {
        HStack(spacing: 32) {
            VStack {
                //followers title and number
                Text("\(followers)")
                    .font(.headline)
                Text("Followers")
                    .font(.caption)
            }

            VStack {
                //following title and number
                Text("\(following)")
                    .font(.headline)
                Text("Following")
                    .font(.caption)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    ProfileStatsView(followers: 120, following: 85)
}
