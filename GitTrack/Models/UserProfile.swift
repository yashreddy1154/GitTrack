//
//  UserProfile.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 2/4/2026.
//

import Foundation

struct UserProfile: Codable {
    let login: String
    let avatar_url: String
    let name: String?
    let bio: String?
    let followers: Int
    let following: Int
}
