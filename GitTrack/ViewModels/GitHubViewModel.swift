//
//  GitHubViewModel.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 31/3/2026.
//
import Foundation
import Combine

@MainActor
class GitHubViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var isLoading: Bool = false // ADD THIS
    
    func fetchRepos(for username: String) async {
        guard let url = URL(string: "https://api.github.com/users/\(username)/repos") else { return }
        
        // UI updates must happen on the main thread
        await MainActor.run { isLoading = true } // START LOADING
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let fetchedData = try decoder.decode([Repository].self, from: data)
            
            await MainActor.run {
                self.repositories = fetchedData
                self.isLoading = false // STOP LOADING
            }
        } catch {
            print("Failed: \(error)")
            await MainActor.run { self.isLoading = false } // STOP ON ERROR
        }
    }
}


