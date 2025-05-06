


import SwiftUI

// custom chat bubble shape for messages
struct ChatBubble: Shape {
    let isFromCurrentUser: Bool // true if message is from current user
    
    func path(in rect: CGRect) -> Path {
        // creates a bubble with a tail on the correct side
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [
                                    .topLeft,
                                    .topRight,
                                    isFromCurrentUser ? .bottomLeft : .bottomRight
                                ],
                                cornerRadii: CGSize(width: 16, height: 16)
        
                                
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatBubble(isFromCurrentUser: true)
}
