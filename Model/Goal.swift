//
//  Goal.swift
//  disso
//
//  Created by Madeha Ahmed on 02/05/2025.
//

import Foundation
import FirebaseFirestore

//goal model for goal created by current user
struct Goal: Identifiable, Codable {
    @DocumentID var id: String? //auto assigned firestore document
    let name: String //name of the goal
    var isDone: Bool //whether is it completed
    let timestamp: Date //when the goal was created
    let userId: String // id of the user
}

