//
//  RepoDetailView.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 2/4/2026.
//  V2 — Detail screen for a single repository.
//        No secondary API calls — just a clean presentation layer.
//

import SwiftUI

struct RepoDetailView: View {
    
    // Passed in from ContentView via NavigationLink(value:).
    let repo: Repository
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // ── HEADER CARD ──────────────────────────────
                headerCard
                
                // ── STATS ROW ────────────────────────────────
                statsRow
                
                // ── "VIEW ON GITHUB" BUTTON ──────────────────
                if let url = URL(string: repo.htmlURL) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "safari.fill")
                            Text("View on GitHub")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(repo.name)
        .navigationBarTitleDisplayMode(.inline)
        
        // ── TOOLBAR: Share Button ────────────────────────
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Native share sheet — shares the repo URL as a string.
                if let url = URL(string: repo.htmlURL) {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                     HEADER CARD                         │
    // └─────────────────────────────────────────────────────────┘
    /// Shows the repo name and description inside a material card.
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Repo name with a book icon
            HStack {
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text(repo.name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            // Description
            if let description = repo.description {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("No description provided.")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    // ┌─────────────────────────────────────────────────────────┐
    // │                      STATS ROW                          │
    // └─────────────────────────────────────────────────────────┘
    /// A horizontal row of three stat cards: Language, Stars, Forks.
    private var statsRow: some View {
        HStack(spacing: 12) {
            
            // Language
            statCard(
                icon: "chevron.left.forwardslash.chevron.right",
                value: repo.language ?? "N/A",
                label: "Language",
                tint: .purple
            )
            
            // Stars
            statCard(
                icon: "star.fill",
                value: "\(repo.stargazersCount)",
                label: "Stars",
                tint: .yellow
            )
            
            // Forks
            statCard(
                icon: "tuningfork",
                value: "\(repo.forksCount)",
                label: "Forks",
                tint: .green
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    /// Reusable stat card with an icon, a bold value, and a caption label.
    private func statCard(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RepoDetailView(repo: Repository(
            id: 1,
            name: "swift-demo",
            description: "A sample repo for previewing the detail view layout.",
            language: "Swift",
            stargazersCount: 128,
            forksCount: 34,
            htmlURL: "https://github.com/octocat/Hello-World"
        ))
        .preferredColorScheme(.dark)
    }
}


