//
//  Repository.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 31/3/2026.
//
import Foundation

struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let stargazers_count: Int
    let html_url: String
}
