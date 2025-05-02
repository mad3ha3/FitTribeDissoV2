import SwiftUI

struct InboxRowView: View {
    let message: Message
    
    var body: some View {
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
                        Text("yesterday")
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
        .contentShape(Rectangle())
    }
}

//#Preview {
  //  InboxRowView()
//}
