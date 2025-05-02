//
//  Goal.swift
//  disso
//
//  Created by Madeha Ahmed on 02/05/2025.
//

import Foundation
import FirebaseFirestore

struct Goal: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    var isDone: Bool
    let timestamp: Date
    let userId: String
}

