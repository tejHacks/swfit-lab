---
title: The Main Actor & Swift 6 Concurrency
summary: UI work on the main thread, isolation and strict checking.
minutes: 8
---
All UI updates must happen on the **main thread**. In Swift that's the **main actor**.

```swift
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var name = ""

    func load() async {
        let profile = await api.fetchProfile()   // may run elsewhere
        name = profile.name                       // back on the main actor: safe UI update
    }
}

// Hop to the main actor from anywhere:
await MainActor.run { label.text = "Done" }
```

SwiftUI views are already main-actor isolated, so their `body` and actions run on the main actor.

## Swift 6 language mode

Swift 6 turns concurrency warnings into **errors**: the compiler proves your code has no data races. Typical messages and fixes:

| Error says... | Usual fix |
|---|---|
| "Sending X risks causing data races" | Make the type `Sendable` (or a struct) |
| "Main actor-isolated property can't be referenced from a nonisolated context" | Mark the caller `@MainActor` or `await` it |
| "Static property is not concurrency-safe" | Make it `let`, or isolate it to an actor |

```swift
// Mark work that doesn't touch actor state as nonisolated
actor Store {
    nonisolated let id = UUID()
    nonisolated func describe() -> String { "Store \(id)" }
}
```

:::tip
Newer Xcode templates can make the **main actor the default** for app code ("approachable concurrency"), so you only opt *out* for background work. Check your target's build settings for **Default Actor Isolation**.
:::

```quiz
[
 {"q": "Where must UI updates happen?", "options": ["Any thread", "The main actor (main thread)", "A background actor", "A detached task"], "answer": 1, "why": "UIKit and SwiftUI must be updated on the main thread."},
 {"q": "What does Swift 6 language mode change?", "options": ["Removes optionals", "Turns data-race warnings into compile errors", "Removes classes", "Makes everything async"], "answer": 1, "why": "Strict concurrency checking becomes an error."}
]
```
