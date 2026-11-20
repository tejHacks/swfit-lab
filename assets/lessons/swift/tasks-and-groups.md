---
title: Tasks, Task Groups & Cancellation
summary: Structured concurrency for many jobs at once.
minutes: 9
---
## Task groups: a dynamic number of child tasks

```swift
func downloadAll(_ urls: [URL]) async throws -> [Data] {
    try await withThrowingTaskGroup(of: Data.self) { group in
        for url in urls {
            group.addTask {
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            }
        }
        var results: [Data] = []
        for try await data in group {      // collect as each finishes
            results.append(data)
        }
        return results
    }
}
```

**Structured concurrency**: child tasks can't outlive their parent scope. If one throws, the others are cancelled automatically.

## Cancellation is cooperative

```swift
let task = Task {
    for page in 1...100 {
        try Task.checkCancellation()          // throws CancellationError if cancelled
        await process(page)
    }
}
task.cancel()
```

## Task priority and detached tasks

```swift
Task(priority: .background) { await cleanUpCache() }
Task.detached { /* doesn't inherit actor or priority: use rarely */ }
```

## AsyncSequence

```swift
for try await line in url.lines {    // stream lines as they download
    print(line)
}

let stream = AsyncStream<Int> { continuation in
    for i in 1...3 { continuation.yield(i) }
    continuation.finish()
}
for await value in stream { print(value) }
```

```quiz
[
 {"q": "What happens to child tasks in a throwing task group when one throws?", "options": ["They keep running", "The others are cancelled", "The app crashes", "They restart"], "answer": 1, "why": "Structured concurrency cancels siblings on error."},
 {"q": "Is cancellation automatic in Swift?", "options": ["Yes, tasks stop instantly", "No, it's cooperative: code must check for it", "Only on the main actor", "Only for detached tasks"], "answer": 1, "why": "Tasks must check Task.isCancelled or call checkCancellation()."}
]
```
