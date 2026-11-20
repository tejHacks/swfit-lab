---
title: async / await
summary: Write asynchronous code that reads like normal code.
minutes: 9
---
Slow work (network, disk, heavy computation) must not freeze the UI. With **async/await**, you mark functions that can suspend and `await` their results.

```swift
func fetchQuote() async throws -> String {
    let url = URL(string: "https://example.com/quote")!
    let (data, response) = try await URLSession.shared.data(from: url)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    return String(decoding: data, as: UTF8.self)
}
```

- `async`: this function can **suspend** (pause without blocking a thread).
- `await`: a possible suspension point; other work runs meanwhile.
- `async throws` + `try await`: async work that can fail.

## Calling async code

```swift
// From synchronous code (e.g. a button tap) start a Task:
Button("Load") {
    Task {
        do {
            quote = try await fetchQuote()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// In SwiftUI, .task runs when the view appears and cancels when it disappears:
Text(quote).task { quote = (try? await fetchQuote()) ?? "Offline" }
```

## Doing things in parallel: async let

```swift
async let profile = api.profile(id: 1)
async let posts = api.posts(userID: 1)
let (p, list) = try await (profile, posts)   // both requests run at the same time
```

:::analogy
`await` is like putting the kettle on and checking your messages while it boils, instead of staring at the kettle.
:::

```quiz
[
 {"q": "What does `await` mean?", "options": ["Block the thread", "A point where the function may suspend while waiting", "Run on a new thread", "Retry"], "answer": 1, "why": "Awaiting suspends without blocking the thread."},
 {"q": "How do you call an async function from a button action?", "options": ["Directly", "Wrap it in Task { }", "Use DispatchQueue.async", "You can't"], "answer": 1, "why": "Task creates an async context from synchronous code."},
 {"q": "What does `async let` enable?", "options": ["Lazy values", "Running child tasks concurrently", "Global variables", "Caching"], "answer": 1, "why": "Multiple async lets run in parallel until awaited."}
]
```
