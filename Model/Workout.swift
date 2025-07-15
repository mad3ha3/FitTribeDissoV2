//
//  Workout.swift
//  disso
//
//  Created by Madeha Ahmed on 14/04/2025.
//

import Foundation
import FirebaseFirestore

//represents a single workout entry in the app and firestore
struct Workout: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String // name of the workout
    let type: String // workout category
    let duration: Int? // workout duration, in mins (optional for strength workouts)
    let caloriesBurned: Int // estimated cals burnt
    let notes: String? // user notes
    let date: Date // workout date
    var userId: String  // Firebase user ID - this is set in workoutViewModel
    var sets: Int? // number of sets for strength workouts
    var reps: Int? // number of reps per set for strength workouts
    var weight: Int? //workout
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, duration, caloriesBurned, notes, date, userId, sets, reps, weight
    }
}



