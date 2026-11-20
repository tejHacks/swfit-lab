---
title: Actors & Sendable
summary: Protect shared mutable state from data races.
minutes: 10
---
A **data race** happens when two threads access the same memory at the same time and at least one writes. The result is random bugs and crashes. Swift 6 catches data races at **compile time**.

## Actors

An **actor** is like a class, but only one task at a time can touch its mutable state.

```swift
actor BankAccount {
    private(set) var balance = 0.0

    func deposit(_ amount: Double) {
        balance += amount
    }

    func withdraw(_ amount: Double) throws {
        guard amount <= balance else { throw BankError.insufficientFunds }
        balance -= amount
    }
}

let account = BankAccount()
await account.deposit(100)          // calls from outside need await
print(await account.balance)
```

## Sendable

A type is **Sendable** if it's safe to pass between concurrent tasks:

- Value types whose properties are all Sendable (most structs and enums) are Sendable automatically.
- Actors are Sendable.
- Classes are Sendable only if they're `final` and have immutable (`let`) Sendable properties, or they use `@unchecked Sendable` with your own locking.

```swift
struct Order: Sendable { let id: Int; let total: Double }

final class Config: Sendable {
    let apiURL: URL
    init(apiURL: URL) { self.apiURL = apiURL }
}
```

## Reentrancy

Inside an actor, every `await` is a point where other calls can run. Re-check assumptions after awaiting:

```swift
actor ImageCache {
    private var cache: [URL: Data] = [:]

    func image(for url: URL) async throws -> Data {
        if let cached = cache[url] { return cached }
        let (data, _) = try await URLSession.shared.data(from: url)
        cache[url] = data          // another call may have filled it meanwhile, and that's fine
        return data
    }
}
```

```quiz
[
 {"q": "What does an actor guarantee?", "options": ["Faster code", "Only one task at a time accesses its mutable state", "Runs on the main thread", "No await needed"], "answer": 1, "why": "Actor isolation serialises access to its state."},
 {"q": "Which is automatically Sendable?", "options": ["A non-final class with var properties", "A struct with only Sendable stored properties", "Any closure", "UIView"], "answer": 1, "why": "Value types with Sendable members conform implicitly."}
]
```
