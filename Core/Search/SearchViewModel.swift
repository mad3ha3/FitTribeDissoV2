
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

// View model to handle user search functionality and state management
@MainActor
class SearchViewModel: ObservableObject {
    // Published properties to update the UI
    @Published var searchText: String = ""    // Current search query
    @Published var users: [User] = []         // Search results
    @Published var isLoading = false          // Loading state indicator
    @Published var errorMessage: String?      // Error message if search fails
    
    // Combine cancellable for managing search subscription
    private var searchCancellable: AnyCancellable?
    // Firestore database reference
    private let db = Firestore.firestore()
    
    init() {
        // Set up search functionality when initialized
        setupSearchPublisher()
    }
    
    // Configure the search publisher with debounce and duplicate removal
    private func setupSearchPublisher() {
        searchCancellable = $searchText
            // Wait for 300ms of no changes before searching
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            // Only search if the text has changed
            .removeDuplicates()
            // Subscribe to text changes and perform search
            .sink { [weak self] searchText in
                guard let self = self else { return }
                Task {
                    await self.performSearch(searchText: searchText)
                }
            }
    }
    
    // Perform the actual search in Firestore
    private func performSearch(searchText: String) async {
        // Ensure user is authenticated
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        // Update loading state
        isLoading = true
        errorMessage = nil
        
        // Clear results if search text is empty
        if searchText.isEmpty {
            self.users = []
            isLoading = false
            return
        }
        
        do {
            // Create Firestore query for users matching the search text
            let query = db.collection("users")
                // Find names that start with the search text
                .whereField("fullname", isGreaterThanOrEqualTo: searchText)
                .whereField("fullname", isLessThanOrEqualTo: searchText + "\u{f8ff}")
                // Limit results for performance
                .limit(to: 10)
            
            // Execute the query
            let snapshot = try await query.getDocuments()
            
            // Process and filter the results
            let filteredUsers = snapshot.documents.compactMap { document -> User? in
                // Try to decode the document and exclude the current user
                guard let user = try? document.data(as: User.self),
                      user.id != currentUserId else {
                    return nil
                }
                return user
            }
            
            // Update the UI with results
            self.users = filteredUsers
        } catch {
            // Handle any errors that occur during the search
            print("DEBUG: Error searching users: \(error.localizedDescription)")
            errorMessage = "Failed to search users"
        }
        
        // Update loading state
        isLoading = false
    }
}
