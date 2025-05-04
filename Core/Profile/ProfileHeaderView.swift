import SwiftUI

struct ProfileHeaderView: View {
    let user: User

    var body: some View {
        VStack(spacing: 12) {
            Text(user.initials)
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.blue))

            Text(user.fullname)
                .font(.title2)
                .fontWeight(.semibold)

            // Show email if it exists 
            if !user.email.isEmpty {
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top)
    }
}

#Preview {
    ProfileHeaderView(user: User.MOCK_USER)
}
