//
//  ContentView.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 31/3/2026.
//


import SwiftUI

struct ContentView: View {
    // This connects your View to your ViewModel
    @StateObject private var viewModel = GitHubViewModel()
    
    // This watches what the user types in the search bar
    @State private var username: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // 1. THE SEARCH BAR
                HStack {
                    TextField("Enter GitHub Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button("Search") {
                        // When tapped, trigger the async network call
                        Task {
                            await viewModel.fetchRepos(for: username)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // 2. THE PROFILE PICTURE (Only shows if there are repos)
                if !viewModel.repositories.isEmpty && !viewModel.isLoading {
                    AsyncImage(url: URL(string: "https://github.com/\(username).png")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding(.bottom, 10)
                }
                
                // 3. THE LIST AREA (Loading vs Empty vs Populated)
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Fetching Repos...")
                        .scaleEffect(1.2)
                    Spacer()
                } else if viewModel.repositories.isEmpty {
                    Spacer()
                    Text("Search for a user to see their repositories.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(viewModel.repositories) { repo in
                        
                        // 4. THE TAPPABLE LINK
                        if let repoURL = URL(string: repo.html_url) {
                            Link(destination: repoURL) {
                                
                                // --- THE ROW UI ---
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(repo.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    if let description = repo.description {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text("\(repo.stargazers_count)")
                                            .font(.caption)
                                        
                                        Spacer()
                                        
                                        if let language = repo.language {
                                            Text(language)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                                // ------------------
                                
                            }
                            .tint(.primary) // Keeps the text black/white instead of hyperlink blue
                        }
                    }
                }
            }
            .navigationTitle("GitTrack")
        }
    }
}

#Preview {
    ContentView()
}
