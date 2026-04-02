//
//  GitTrackApp.swift
//  GitTrack
//
//  Created by Yashwanth Reddy on 2/4/2026.
//  V2 — Standard SwiftUI app entry point.
//

import SwiftUI

@main
struct GitTrackApp: App {
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Forces dark mode across the entire app for a sleek, modern look.
                .preferredColorScheme(.dark)
        }
    }
}


