---
title: Enums
summary: Cases, raw values, associated values and methods.
minutes: 9
---
```swift
enum Direction {
    case north, south, east, west
}

var heading = Direction.north
heading = .east           // type inferred

switch heading {
case .north: print("Up")
case .south: print("Down")
case .east, .west: print("Sideways")
}
```

## Raw values

```swift
enum Planet: Int, CaseIterable {
    case mercury = 1, venus, earth, mars
}
Planet.earth.rawValue          // 3
Planet(rawValue: 4)            // .mars (optional: might not exist)
Planet.allCases.count          // 4

enum HTTPMethod: String { case get = "GET", post = "POST" }
```

## Associated values: data per case

```swift
enum PaymentResult {
    case success(transactionID: String)
    case failure(reason: String, retryable: Bool)
    case pending
}

func handle(_ result: PaymentResult) {
    switch result {
    case .success(let id):
        print("Paid! \(id)")
    case .failure(let reason, retryable: true):
        print("Try again: \(reason)")
    case .failure(let reason, _):
        print("Failed: \(reason)")
    case .pending:
        print("Waiting…")
    }
}
```

## Methods and computed properties

```swift
enum Theme: String, CaseIterable {
    case light, dark, system
    var title: String { rawValue.capitalized }
}
```

:::tip
Enums with associated values are perfect for **states**: `enum LoadState { case idle, loading, loaded([Item]), failed(Error) }`. The compiler forces you to handle every state.
:::

```quiz
[
 {"q": "What does Planet(rawValue: 9) return if there's no case 9?", "options": ["Crash", "nil", "mercury", "0"], "answer": 1, "why": "Failable init from raw value returns an optional."},
 {"q": "Which protocol gives you allCases?", "options": ["Equatable", "CaseIterable", "Codable", "Hashable"], "answer": 1, "why": "CaseIterable synthesizes allCases."}
]
```
