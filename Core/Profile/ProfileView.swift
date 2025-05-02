//
//  ProfileView.swift
//  disso
//
//  Created by Madeha Ahmed on 07/04/2025.
//

import SwiftUI
import FirebaseAuth

//displays user profile information w sign out option
struct ProfileView: View {
    let user: User?
    @State private var showingSignOutAlert = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var displayedUser: User? {
        user ?? authViewModel.currentUser
    }
    
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section("Personal Information") {
                    if let displayedUser = displayedUser {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(displayedUser.fullname)
                                    .font(.headline)
                                Spacer()
                                Text(displayedUser.initials)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(Color.blue))
                            }
                            
                            Text(displayedUser.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("Loading user information...")
                            .foregroundColor(.gray)
                    }
                }
                
                // Actions Section
                if user == nil {
                    Section("Sign out") {
                        // Sign Out Button
                        Button(role: .destructive) {
                            showingSignOutAlert = true
                        } label: {
                            HStack {
                                Text("Sign Out")
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                }
            }
            
            
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func signOut() {
        // First dismiss the view
        dismiss()
        
        // Then sign out
        authViewModel.signOut()
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    authViewModel.currentUser = User.MOCK_USER
    return ProfileView(user: nil)
        .environmentObject(authViewModel)
}
