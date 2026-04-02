//
//  GitHubViewModel.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 2/4/2026.
//  V2 — ViewModel with pagination and sorting.
//

import Foundation

// MARK: - Sort Option
/// Simple enum the user can pick from to reorder the repo list.
enum SortOption: String, CaseIterable, Identifiable {
    case none         = "Default"
    case mostStars    = "Most Stars"
    case alphabetical = "A → Z"
    
    var id: String { rawValue }
}

// MARK: - ViewModel
@MainActor
class GitHubViewModel: ObservableObject {
    
    // MARK: Published State
    @Published var userProfile: UserProfile?       = nil
    @Published var repositories: [Repository]      = []
    @Published var isLoading: Bool                  = false
    @Published var errorMessage: String?            = nil
    @Published var selectedSortOption: SortOption   = .none
    
    // MARK: Pagination State
    /// Current page of repos we've fetched (GitHub pages start at 1).
    private var page: Int = 1
    /// True while we're loading the *next* page (not the initial load).
    @Published var isFetchingMore: Bool = false
    /// Flips to true when a page comes back with fewer than 30 repos.
    private var hasReachedEnd: Bool = false
    /// Stores the username so `loadMoreRepos()` knows who to fetch.
    private var currentUsername: String = ""
    
    // MARK: - Sorted Repositories (Computed)
    /// Returns the repo array sorted by whatever the user has picked.
    var sortedRepositories: [Repository] {
        switch selectedSortOption {
        case .none:
            return repositories
        case .mostStars:
            return repositories.sorted { $0.stargazersCount > $1.stargazersCount }
        case .alphabetical:
            return repositories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
    
    // MARK: - Fetch User + First Page of Repos
    /// Kicks off a fresh search: fetches the user profile and the first page of repos.
    func fetchRepos(for username: String) async {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUsername.isEmpty else { return }
        
        // Build URLs
        guard let userURL  = URL(string: "https://api.github.com/users/\(cleanUsername)"),
              let reposURL = URL(string: "https://api.github.com/users/\(cleanUsername)/repos?per_page=30&page=1")
        else { return }
        
        // Reset all state for a brand-new search
        currentUsername = cleanUsername
        page           = 1
        hasReachedEnd  = false
        isLoading      = true
        repositories   = []
        userProfile    = nil
        errorMessage   = nil
        
        // Build authenticated requests
        var userRequest  = URLRequest(url: userURL)
        var reposRequest = URLRequest(url: reposURL)
        applyAuthHeader(to: &userRequest)
        applyAuthHeader(to: &reposRequest)
        
        do {
            // --- Fetch user profile ---
            let (userData, userResponse) = try await URLSession.shared.data(for: userRequest)
            
            // Check for common HTTP errors before decoding.
            if let httpStatus = (userResponse as? HTTPURLResponse)?.statusCode {
                if httpStatus == 403 {
                    errorMessage = "API Rate Limit reached. Please try again later."
                    isLoading = false
                    return
                } else if httpStatus == 404 {
                    errorMessage = "User not found."
                    isLoading = false
                    return
                }
            }
            
            // --- Fetch first page of repos ---
            let (repoData, _) = try await URLSession.shared.data(for: reposRequest)
            
            // Decode
            let decoder = JSONDecoder()
            let fetchedUser  = try decoder.decode(UserProfile.self, from: userData)
            let fetchedRepos = try decoder.decode([Repository].self, from: repoData)
            
            // Update state
            userProfile   = fetchedUser
            repositories  = fetchedRepos
            isLoading     = false
            
            // If we got fewer than 30, there's no next page.
            if fetchedRepos.count < 30 {
                hasReachedEnd = true
            }
            
        } catch {
            errorMessage = "A network error occurred."
            isLoading    = false
        }
    }
    
    // MARK: - Load More Repos (Pagination)
    /// Call this when the user scrolls near the bottom. It appends the next
    /// page of repos to the existing array.
    func loadMoreRepos() async {
        // Guard: don't double-fetch, and stop if we've already loaded everything.
        guard !isFetchingMore, !hasReachedEnd, !currentUsername.isEmpty else { return }
        
        let nextPage = page + 1
        guard let url = URL(string:
            "https://api.github.com/users/\(currentUsername)/repos?per_page=30&page=\(nextPage)")
        else { return }
        
        isFetchingMore = true
        
        var request = URLRequest(url: url)
        applyAuthHeader(to: &request)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let newRepos   = try JSONDecoder().decode([Repository].self, from: data)
            
            // Append new repos and advance the page counter.
            repositories.append(contentsOf: newRepos)
            page = nextPage
            
            if newRepos.count < 30 {
                hasReachedEnd = true
            }
        } catch {
            // Silently fail on pagination errors — the user can retry by scrolling again.
            print("Pagination error: \(error.localizedDescription)")
        }
        
        isFetchingMore = false
    }
    
    // MARK: - Private Helpers
    
    /// Reads the GitHub PAT from `Secrets.plist` (if it exists) and returns it.
    private func getGitHubToken() -> String? {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist    = NSDictionary(contentsOfFile: filePath),
              let token    = plist["GitHubToken"] as? String,
              !token.isEmpty
        else { return nil }
        return token
    }
    
    /// Attaches the Bearer token to a request, if a token is available.
    private func applyAuthHeader(to request: inout URLRequest) {
        if let token = getGitHubToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
