//
//  GymAttendance.swift
//  disso
//
//  Created by Madeha Ahmed on 15/04/2025.
//

import Foundation
import FirebaseFirestore

//checks when the user checks in for gym attendance
struct GymAttendance: Identifiable, Codable {
    @DocumentID var id: String? //auto assigned firestore document
    let userId: String // id of the user
    let timestamp: Date//timestamp of when they checked in
    
    //only date is taken, to check for check in today
    var date: Date {
        Calendar.current.startOfDay(for: timestamp)
    }
    
    //this is the intitaliser for creating new attendance records
    init(userId: String, timestamp: Date) {
        self.userId = userId
        self.timestamp = timestamp
    }
}
