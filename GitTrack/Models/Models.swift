//
//  Models.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 2/4/2026.
//  V2 — All API models in one place. Simple Codable structs, no DTOs.
//

import Foundation

// MARK: - User Profile
/// Represents a GitHub user's public profile.
/// Maps directly to the JSON from: GET /users/{username}
struct UserProfile: Codable, Identifiable, Hashable {
    
    // GitHub's unique user ID — doubles as our Identifiable id.
    let id: Int
    let login: String
    let avatarURL: String
    let name: String?
    let bio: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
    
    // MARK: CodingKeys
    // Maps GitHub's snake_case JSON keys to Swift's camelCase properties.
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL  = "avatar_url"
        case name
        case bio
        case publicRepos = "public_repos"
        case followers
        case following
    }
}

// MARK: - Repository
/// Represents a single GitHub repository.
/// Maps directly to the JSON from: GET /users/{username}/repos
struct Repository: Codable, Identifiable, Hashable {
    
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let htmlURL: String
    
    // MARK: CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case language
        case stargazersCount = "stargazers_count"
        case forksCount      = "forks_count"
        case htmlURL         = "html_url"
    }
}


