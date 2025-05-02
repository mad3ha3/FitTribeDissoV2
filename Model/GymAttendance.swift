//
//  GymAttendance.swift
//  disso
//
//  Created by Madeha Ahmed on 15/04/2025.
//

import Foundation
import FirebaseFirestore

struct GymAttendance: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let timestamp: Date
    
    var date: Date {
        Calendar.current.startOfDay(for: timestamp)
    }
    
    init(userId: String, timestamp: Date) {
        self.userId = userId
        self.timestamp = timestamp
    }
}
