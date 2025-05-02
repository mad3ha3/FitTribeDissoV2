//
//  User.swift
//  disso
//
//  Created by Madeha Ahmed on 07/04/2025.
//

import Foundation

struct User: Identifiable, Codable, Equatable { //Codable protocol allows  us to take the incoming raw data and map it into a data object
    let id: String  //firebase user UID
    let fullname: String
    let email: String
    //var friends: [String]? = []
    
    var initials: String {  //users initials from their full name
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

// MARK: - Mock User
extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Test One", email: "test@egmail.com") //used for previews or testing without backend connection
}
