# GitTrack 🚀

GitTrack is a native iOS application built to quickly explore GitHub profiles and repositories. Developed entirely in Swift using modern SwiftUI, this project leverages an MVVM architecture and `URLSession` to interact asynchronously with the GitHub REST API. It allows users to search for any GitHub handle, instantly view their profile avatar, and scroll through a dynamic, interactive list of their public repositories.

## 🎥 App Demo
[Watch the video demo on YouTube here](https://youtube.com/shorts/bSlmRkjJWLI)

## 🛠️ Tech Stack
* **Language:** Swift
* **UI Framework:** SwiftUI
* **Architecture:** MVVM (Model-View-ViewModel)
* **Networking:** `URLSession` with `async/await`
* **Data Parsing:** `Codable` (JSONDecoder)

## 🚀 Current Features
* Live search functionality for GitHub users.
* Asynchronous image loading (`AsyncImage`) for user avatars.
* Clean, declarative UI using SwiftUI `List` and `NavigationStack`.
* Direct in-app web routing to individual repositories.
* Responsive loading states and error handling.

## 🗺️ Planned Features
I am actively expanding this project to learn deeper iOS concepts. Upcoming features include:
* **Sorting & Filtering:** Adding the ability to sort repositories by star count or filter by primary programming language.
* **Pagination:** Implementing infinite scrolling to smoothly load users with hundreds of repositories.
* **User Stats:** Fetching and displaying follower counts and bio information on the main screen.
