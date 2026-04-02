import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GitHubViewModel()
    @State private var username: String = ""
    
    // NEW: Tracks if the big profile has been scrolled off-screen
    @State private var isProfileVisible: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) { // spacing: 0 keeps the transitions tight
                
                // 1. THE SEARCH BAR
                HStack {
                    TextField("Enter GitHub Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button("Search") {
                        Task {
                            await viewModel.fetchRepos(for: username)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // 2. THE COMPACT STICKY HEADER
                // This ONLY appears when the big profile scrolls off-screen
                if let user = viewModel.userProfile, !viewModel.isLoading, !isProfileVisible {
                    HStack {
                        AsyncImage(url: URL(string: user.avatar_url)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        
                        Text(user.login)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    // This creates the smooth slide-down animation
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Divider() // Adds a clean line under the search/sticky area
                
                // 3. THE MAIN CONTENT AREA
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Fetching Data...")
                        .scaleEffect(1.2)
                    Spacer()
                    
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.headline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                    
                } else if viewModel.repositories.isEmpty {
                    Spacer()
                    Text("Search for a user to see their repositories.")
                        .foregroundColor(.gray)
                    Spacer()
                    
                } else {
                    
                    // 4. THE SCROLLING LIST
                    // By opening the List block, we can put multiple different things inside it
                    List {
                        
                        // --- A. THE BIG PROFILE DASHBOARD ---
                        if let user = viewModel.userProfile {
                            VStack(spacing: 8) {
                                AsyncImage(url: URL(string: user.avatar_url)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                                
                                if let name = user.name {
                                    Text(name).font(.title2).fontWeight(.bold)
                                }
                                
                                Text("@\(user.login)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                }
                                
                                HStack(spacing: 20) {
                                    Label("\(user.followers) Followers", systemImage: "person.2.fill")
                                    Label("\(user.following) Following", systemImage: "person.fill.checkmark")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity) // Centers the profile
                            .padding(.vertical, 10)
                            .listRowSeparator(.hidden) // Removes the line under the profile
                            .listRowBackground(Color.clear)
                            
                            // NEW: THE TRIGGERS
                            // When this block appears/disappears, it flips the switch to animate the compact header
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.2)) { isProfileVisible = true }
                            }
                            .onDisappear {
                                withAnimation(.easeInOut(duration: 0.2)) { isProfileVisible = false }
                            }
                        }
                        // ------------------------------------
                        
                        
                        // --- B. THE REPOSITORIES ---
                        ForEach(viewModel.repositories) { repo in
                            if let repoURL = URL(string: repo.html_url) {
                                Link(destination: repoURL) {
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
                                            Text("\(repo.stargazers_count)").font(.caption)
                                            
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
                                }
                                .tint(.primary)
                            }
                        }
                        // ---------------------------
                        
                    }
                    .listStyle(.plain) // Changes the list style so it stretches edge-to-edge
                }
            }
            .navigationTitle("GitTrack")
            .navigationBarTitleDisplayMode(.inline) // Makes the main title smaller to save space
        }
    }
}

#Preview {
    ContentView()
}
