import SwiftUI

struct InboxRowView: View {
    let message: Message
    
    var body: some View {
        ZStack {
            // Card background with yellow shadow
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color("AppOrange"), radius: 8, x: 0, y: 0)

            // Row content
            HStack(alignment: .center, spacing: 12) {
                // Profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.systemGray4))
                
                // Message Content
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(message.user?.fullname ?? "")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                    
                    Text(message.messageText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

//#Preview {
  //  InboxRowView()
//}
