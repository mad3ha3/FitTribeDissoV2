//
//  LeaderboardUser.swift
//  disso
//
//  Created by Madeha Ahmed on 15/04/2025.
//

import Foundation

//this model is used for a user in the leaderboard
struct LeaderboardUser: Identifiable {
    let id: String //user id
    let fullname: String // users full name
    let points: Int //users point
}
