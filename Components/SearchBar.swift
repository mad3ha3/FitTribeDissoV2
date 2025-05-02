
import SwiftUI

// A reusable search bar component that provides a text input field with search and clear functionality
struct SearchBar: View {
    // Binding to the search text that will be updated as the user types
    @Binding var text: String
    // Binding to track whether the search bar is currently being used
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .frame(width: 20, height: 20)
            
            // Text input field
            TextField("Search Users", text: $text)
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .onTapGesture {
                    isSearching = true
                }
            
            // Clear button
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// Preview provider for the SearchBar
#Preview {
    SearchBar(text: .constant(""), isSearching: .constant(false))
}
