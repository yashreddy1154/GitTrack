import Foundation
import Combine

@MainActor
class GitHubViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var userProfile: UserProfile? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // NEW: Helper function to safely read the token
    private func getGitHubToken() -> String? {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let token = plist["GitHubToken"] as? String,
              !token.isEmpty else {
            return nil
        }
        return token
    }
    
    func fetchRepos(for username: String) async {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let userUrl = URL(string: "https://api.github.com/users/\(cleanUsername)"),
              let reposUrl = URL(string: "https://api.github.com/users/\(cleanUsername)/repos") else { return }
        
        await MainActor.run {
            self.isLoading = true
            self.repositories = []
            self.userProfile = nil
            self.errorMessage = nil
        }
        
        // 1. Setup Requests
        var userRequest = URLRequest(url: userUrl)
        var reposRequest = URLRequest(url: reposUrl)
        
        // 2. Safely Inject Token ONLY if it exists
        if let token = getGitHubToken() {
            userRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            reposRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Running authenticated search...") // Proves to you it's working
        } else {
            print("Running anonymous search...")
        }
        
        do {
            let (userData, userResponse) = try await URLSession.shared.data(for: userRequest)
            
            if let httpResponse = userResponse as? HTTPURLResponse {
                if httpResponse.statusCode == 403 {
                    self.errorMessage = "API Rate Limit reached. Please try again later."
                    self.isLoading = false
                    return
                } else if httpResponse.statusCode == 404 {
                    self.errorMessage = "User not found."
                    self.isLoading = false
                    return
                }
            }
            
            let (repoData, _) = try await URLSession.shared.data(for: reposRequest)
            
            let decoder = JSONDecoder()
            let fetchedUser = try decoder.decode(UserProfile.self, from: userData)
            let fetchedRepos = try decoder.decode([Repository].self, from: repoData)
            
            await MainActor.run {
                self.userProfile = fetchedUser
                self.repositories = fetchedRepos
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "A network error occurred."
                self.isLoading = false
            }
        }
    }
}
