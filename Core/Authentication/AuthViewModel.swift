//
//  AuthViewModel.swift
//  disso
//
//  Created by Madeha Ahmed on 07/04/2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}


@MainActor //need to publish all UI updates on the main thread
class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User? //current firebase session
    @Published var currentUser: User? //current user object
    
    
    
    init(){ //initialises and attempts to fetch the user if already signed in
        self.userSession = Auth.auth().currentUser //when initialising it will check if there is a current user which is stored locally assisted by firebase
        
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws { //sign in a user
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: USER SIGN IN FAILED \(error.localizedDescription)")
            throw error
        }
    }
    
    //asyncronous function that potentially throws an error which is what happens in the catch block if anything goes wrong
    
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws { //creates a new user and stores their profile in firestore
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password) //create user using firebase code, await the result of it and store it in the result property
            self.userSession = result.user // if there is a result back then it sets the userSession property
            let user = User(id: result.user.uid, fullname: fullname, email: email) //create user object
            let encodedUser = try Firestore.Encoder().encode(user) //encode that object using the codable protocol
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser) //upload that data to the firestore, and how the database is created on firebase, saves user information in backend
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }

    }

    func signOut() {
        do {
            try Auth.auth().signOut() //signs user out on backend
            self.userSession = nil //removes user session and takes user back to login screen
            self.currentUser = nil //removes current user data model
        } catch {
            print("DEBUG: USER SIGN OUT FAILED \(error.localizedDescription)")
        }
    }


    //fetches the user document from firestore and decodes into a 'User' object
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        //print("DEBUG: current user is \(self.currentUser)")
    }
    
}
