---
title: App Architecture & Shipping
summary: MVVM, project structure, performance and the App Store.
minutes: 9
---
## MVVM in SwiftUI

```swift
@Observable
@MainActor
final class PostsViewModel {
    enum State { case idle, loading, loaded([Post]), failed(String) }
    private(set) var state = State.idle
    private let api: any PostsAPI

    init(api: any PostsAPI) { self.api = api }

    func load() async {
        state = .loading
        do { state = .loaded(try await api.posts()) }
        catch { state = .failed(error.localizedDescription) }
    }
}

struct PostsScreen: View {
    @State var model: PostsViewModel
    var body: some View {
        Group {
            switch model.state {
            case .idle, .loading: ProgressView()
            case .loaded(let posts): List(posts) { Text($0.title) }
            case .failed(let message): ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))
            }
        }
        .task { await model.load() }
    }
}
```

**View** = layout only. **ViewModel** = state and logic (testable with no UI). **Model / Services** = data and networking.

## Folder structure

```text
MyApp/
  App/            MyApp.swift, AppDependencies.swift
  Features/
    Posts/        PostsScreen.swift, PostsViewModel.swift
    Settings/
  Services/       APIClient.swift, KeychainStore.swift
  Models/         Post.swift
  Resources/      Assets.xcassets, Localizable.xcstrings
```

## Performance checklist

- Measure with **Instruments** (Time Profiler, SwiftUI, Allocations, Leaks).
- Keep `body` cheap: no heavy work or formatting allocations inside it.
- Use `LazyVStack` and `List` for long content.
- Mark classes `final`; prefer structs.
- Avoid retain cycles in closures (`[weak self]`).

## Shipping to the App Store

1. Join the **Apple Developer Program** ($99/year).
2. Set the bundle ID, version and build number; add an app icon.
3. **Product → Archive** in Xcode, then **Distribute App → App Store Connect**.
4. Test with **TestFlight**, fill in the listing and privacy details, and submit for review.

```quiz
[
 {"q": "In MVVM, where should networking and state logic live?", "options": ["Inside body", "The ViewModel / services", "The asset catalog", "The App struct only"], "answer": 1, "why": "Views stay simple; ViewModels hold testable logic."},
 {"q": "Which tool finds slow code and leaks?", "options": ["Simulator", "Instruments", "TestFlight", "Interface Builder"], "answer": 1, "why": "Instruments profiles CPU, memory, leaks and more."}
]
```
