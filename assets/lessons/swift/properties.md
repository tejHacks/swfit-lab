---
title: Properties: Computed, Observers & Lazy
summary: More than stored values.
minutes: 8
---
## Computed properties

```swift
struct Rectangle {
    var width: Double
    var height: Double

    var area: Double { width * height }        // read-only computed

    var square: Bool {
        get { width == height }
    }
}
```

## Property observers

```swift
struct Account {
    var balance: Double = 0 {
        willSet { print("About to change to \(newValue)") }
        didSet {
            if balance < 0 { print("⚠️ Overdrawn by \(-balance)") }
        }
    }
}
```

## lazy

```swift
final class ReportScreen {
    lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()   // created only the first time it's used
}
```

## Access to setters

```swift
struct Counter {
    private(set) var value = 0      // readable outside, writable only inside
    mutating func increment() { value += 1 }
}
```

```quiz
[
 {"q": "When does didSet run?", "options": ["Before the change", "After the change", "On init", "Never for structs"], "answer": 1, "why": "didSet runs right after the new value is stored (not during init)."},
 {"q": "What does `lazy` mean?", "options": ["Thread-safe", "Computed on first access", "Read-only", "Static"], "answer": 1, "why": "Lazy properties are initialized when first used."}
]
```
