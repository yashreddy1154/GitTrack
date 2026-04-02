# 🔍 GitTrack

**A modern iOS app to explore GitHub user profiles and repositories.**

Built with 100% native Apple frameworks as a portfolio project demonstrating clean SwiftUI architecture, async networking, and thoughtful UI design.

> **Target:** iOS 17+ · **Language:** Swift 5.9+ · **UI:** SwiftUI

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔎 **User Search** | Search any GitHub username to view their profile and public repositories. |
| 🧠 **Smart Collapsing Header** | A full profile dashboard that smoothly collapses into a compact sticky header as you scroll — inspired by apps like Twitter/X. |
| ♾️ **Infinite Scrolling** | Repositories load page-by-page (30 at a time) as you scroll, using simple cursor-based pagination. |
| 🔤 **Local Sorting** | Sort repos by **Most Stars** or **Alphabetically** via a toolbar menu — instant, no extra API calls. |
| 🕐 **Recent Searches** | Your last 5 searches are saved locally and shown as quick-access capsule buttons below the search bar. |
| 📄 **Repository Detail View** | Tap any repo to see its stats (language, stars, forks) in a polished detail screen with a **"View on GitHub"** button and a native **Share** sheet. |
| 🌙 **Dark Mode** | Ships with a sleek dark-mode-first design. |

---

## 🏗️ Architecture

```
GitTrack/
├── GitTrackApp.swift          # App entry point
├── Models/
│   └── Models.swift           # UserProfile & Repository (Codable structs)
├── ViewModels/
│   └── GitHubViewModel.swift  # MVVM business logic, networking, pagination
└── Views/
    ├── ContentView.swift      # Main search screen with smart header
    └── RepoDetailView.swift   # Repository detail screen
```

### 📐 MVVM Pattern

The app follows a standard **Model–View–ViewModel** architecture:

- **Model** → Simple `Codable` structs that map directly to the GitHub API JSON.
- **ViewModel** → A single `@MainActor ObservableObject` that owns all state and networking logic.
- **View** → Declarative SwiftUI views that read from the ViewModel's `@Published` properties.

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **UI** | SwiftUI (NavigationStack, AsyncImage, ShareLink) |
| **Networking** | URLSession + async/await |
| **Data** | Codable structs with CodingKeys |
| **Persistence** | @AppStorage / UserDefaults |
| **Concurrency** | Swift structured concurrency (async/await) |
| **Min Deployment** | iOS 17.0 |

---

## 💡 Engineering Decisions

> *"Why didn't you use Alamofire / CoreData / SwiftData / Realm?"*

This was a deliberate choice. Here's why:

- **URLSession over Alamofire** — Apple's native `URLSession` with `async/await` is clean, lightweight, and requires zero dependencies. For a project that makes 2–3 simple GET requests, adding a networking library would be unnecessary overhead. Understanding `URLSession` is a fundamental skill.

- **Codable structs over CoreData / SwiftData / Realm** — The app doesn't need a persistent database. All data is fetched fresh from the API and displayed immediately. Using a database would add complexity (schemas, migrations, contexts) with zero user-facing benefit.

- **@AppStorage over a database** — Recent searches are just strings. A comma-separated `UserDefaults` entry is the right tool for the job — simple, native, and zero boilerplate.

- **No DTOs or abstraction layers** — The `Codable` structs decode directly from the API response. Adding Data Transfer Objects would be enterprise-level indirection that adds lines of code without adding value at this scale.

**The goal:** Master Apple's native frameworks first. Add third-party tools only when they solve a real problem.

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15+ (with iOS 17 SDK)
- A GitHub account (for an optional Personal Access Token)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/GitTrack.git
   cd GitTrack
   ```

2. **Set up the API token (optional but recommended):**

   GitHub's public API has a rate limit of **60 requests/hour** for unauthenticated users. To increase this to **5,000 requests/hour**, add a Personal Access Token:

   - Go to [GitHub → Settings → Developer Settings → Personal Access Tokens → Tokens (classic)](https://github.com/settings/tokens).
   - Generate a new token with **no special scopes** (public access is enough).
   - In the Xcode project, find the file `Secrets-Sample.plist`.
   - **Duplicate** it and rename the copy to `Secrets.plist`.
   - Open `Secrets.plist` and paste your token as the value for `GitHubToken`.

   > ⚠️ `Secrets.plist` is listed in `.gitignore` — your token will **never** be committed.

3. **Open and run:**
   ```
   open GitTrack.xcodeproj
   ```
   Select an iOS 17+ simulator and hit **⌘R**.

---

## 📸 Screenshots

<!-- Add your simulator screenshots here -->
<!-- ![Home Screen](screenshots/home.png) -->
<!-- ![Detail View](screenshots/detail.png) -->

*Coming soon — screenshots will be added after final UI polish.*

---

## 📝 License

This project is open source and available for learning purposes.

---


*Built with ❤️ using SwiftUI as a portfolio project for iOS internship preparation.*

