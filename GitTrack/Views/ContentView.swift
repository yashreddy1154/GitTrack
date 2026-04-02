//
//  ContentView.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 2/4/2026.
//  V2 — Main screen with search, recent searches, sorting, pagination,
//        and the smart collapsing profile header.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = GitHubViewModel()
    @State private var username: String = ""
    
    // Tracks whether the large profile card is visible in the scroll area.
    // When it scrolls off-screen, a compact sticky header slides in.
    @State private var isProfileVisible: Bool = true
    
    // MARK: - Recent Searches (Simple UserDefaults Persistence)
    // Stored as a comma-separated string, e.g. "octocat,torvalds,yashw".
    @AppStorage("recentSearches") private var recentSearchesRaw: String = ""
    
    /// Computed helper that converts the raw string to an array.
    private var recentSearches: [String] {
        recentSearchesRaw
            .split(separator: ",")
            .map(String.init)
    }
    
    /// Saves a username to the front of the recent list, capped at 5.
    private func saveToRecents(_ name: String) {
        var list = recentSearches.filter { $0 != name } // Remove duplicates
        list.insert(name, at: 0)                        // Add to front
        if list.count > 5 { list = Array(list.prefix(5)) }
        recentSearchesRaw = list.joined(separator: ",")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // ── 1. SEARCH BAR ──────────────────────────────────
                searchBar
                
                // ── 2. RECENT SEARCHES (horizontal capsules) ──────
                if !recentSearches.isEmpty && viewModel.userProfile == nil && !viewModel.isLoading {
                    recentSearchesCapsules
                }
                
                // ── 3. COMPACT STICKY HEADER ──────────────────────
                // Slides in when the large profile card scrolls off-screen.
                if let user = viewModel.userProfile, !viewModel.isLoading, !isProfileVisible {
                    compactHeader(for: user)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Divider()
                
                // ── 4. MAIN CONTENT AREA ──────────────────────────
                mainContent
            }
            .navigationTitle("GitTrack")
            .navigationBarTitleDisplayMode(.inline)
            
            // ── TOOLBAR: Sort Picker ──────────────────────────
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
            }
            
            // ── NAVIGATION DESTINATION ────────────────────────
            // When a repo row is tapped, navigate to its detail view.
            .navigationDestination(for: Repository.self) { repo in
                // Placeholder — we'll build RepoDetailView in the next prompt.
                RepoDetailView(repo: repo)
            }
        }
    }
    
    // MARK: - Subviews
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                     SEARCH BAR                          │
    // └─────────────────────────────────────────────────────────┘
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search GitHub username…", text: $username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit { performSearch() }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                performSearch()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                  RECENT SEARCHES                        │
    // └─────────────────────────────────────────────────────────┘
    private var recentSearchesCapsules: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Recent")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recentSearches, id: \.self) { name in
                        Button {
                            username = name
                            performSearch()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption2)
                                Text(name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .tint(.primary)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 6)
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                  COMPACT HEADER                         │
    // └─────────────────────────────────────────────────────────┘
    /// Slim header that replaces the full profile card when it scrolls away.
    private func compactHeader(for user: UserProfile) -> some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: user.avatarURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 34, height: 34)
            .clipShape(Circle())
            
            Text(user.login)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            // Quick stats in the compact bar
            Label("\(user.followers)", systemImage: "person.2.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                   SORT MENU                             │
    // └─────────────────────────────────────────────────────────┘
    private var sortMenu: some View {
        Menu {
            // This Picker automatically shows a checkmark next to the active option.
            Picker("Sort By", selection: $viewModel.selectedSortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolRenderingMode(.hierarchical)
        }
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                  MAIN CONTENT                           │
    // └─────────────────────────────────────────────────────────┘
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            // ── Loading ──
            Spacer()
            ProgressView("Fetching data…")
                .scaleEffect(1.2)
            Spacer()
            
        } else if let error = viewModel.errorMessage {
            // ── Error ──
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                Text(error)
                    .font(.headline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            Spacer()
            
        } else if viewModel.sortedRepositories.isEmpty {
            // ── Empty State ──
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Search for a user to see their repos.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            
        } else {
            // ── Repo List ──
            repoList
        }
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                    REPO LIST                            │
    // └─────────────────────────────────────────────────────────┘
    private var repoList: some View {
        List {
            // ── A. LARGE PROFILE DASHBOARD ──
            if let user = viewModel.userProfile {
                profileDashboard(for: user)
            }
            
            // ── B. REPOSITORY ROWS ──
            ForEach(viewModel.sortedRepositories) { repo in
                NavigationLink(value: repo) {
                    repoRow(for: repo)
                }
                .tint(.primary)
            }
            
            // ── C. PAGINATION TRIGGER ──
            if viewModel.isFetchingMore {
                HStack {
                    Spacer()
                    ProgressView("Loading more…")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else if !viewModel.sortedRepositories.isEmpty {
                // Invisible trigger — fires loadMoreRepos when it appears.
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        Task { await viewModel.loadMoreRepos() }
                    }
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │               PROFILE DASHBOARD                        │
    // └─────────────────────────────────────────────────────────┘
    /// The large profile card that sits at the top of the list.
    private func profileDashboard(for user: UserProfile) -> some View {
        VStack(spacing: 10) {
            // Avatar
            AsyncImage(url: URL(string: user.avatarURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 90, height: 90)
            .clipShape(Circle())
            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            
            // Name
            if let name = user.name {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            // Username
            Text("@\(user.login)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Bio
            if let bio = user.bio {
                Text(bio)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            // Stats row: Repos · Followers · Following
            HStack(spacing: 24) {
                statBadge(count: user.publicRepos, label: "Repos",     icon: "book.closed.fill")
                statBadge(count: user.followers,   label: "Followers", icon: "person.2.fill")
                statBadge(count: user.following,    label: "Following", icon: "person.fill.checkmark")
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        // Smart header triggers — flip the compact header when this scrolls away.
        .onAppear  { withAnimation(.easeInOut(duration: 0.2)) { isProfileVisible = true  } }
        .onDisappear { withAnimation(.easeInOut(duration: 0.2)) { isProfileVisible = false } }
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                   REPO ROW                              │
    // └─────────────────────────────────────────────────────────┘
    /// A single, polished repository row.
    private func repoRow(for repo: Repository) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Repo name
            Text(repo.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            // Description (if available)
            if let description = repo.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            // Stats: Stars · Forks · Language
            HStack(spacing: 16) {
                Label("\(repo.stargazersCount)", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
                
                Label("\(repo.forksCount)", systemImage: "tuningfork")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if let language = repo.language {
                    Text(language)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Helpers
    
    /// Small stat column used inside the profile dashboard.
    private func statBadge(count: Int, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    /// Shared logic for triggering a search.
    private func performSearch() {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        saveToRecents(trimmed)
        Task { await viewModel.fetchRepos(for: trimmed) }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
