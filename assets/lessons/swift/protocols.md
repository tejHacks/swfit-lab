---
title: Protocols
summary: Define capabilities; the heart of Swift's design.
minutes: 10
---
A **protocol** describes what a type can do, without saying how. Types **conform** by implementing the requirements.

```swift
protocol Shape {
    var area: Double { get }
    func describe() -> String
}

struct Circle: Shape {
    var radius: Double
    var area: Double { .pi * radius * radius }
    func describe() -> String { "Circle with area \(area.formatted())" }
}

struct Square: Shape {
    var side: Double
    var area: Double { side * side }
    func describe() -> String { "Square \(side)×\(side)" }
}

let shapes: [any Shape] = [Circle(radius: 1), Square(side: 3)]
for s in shapes { print(s.describe()) }
```

## Default implementations with extensions

```swift
extension Shape {
    func describe() -> String { "A shape with area \(area)" }   // used unless the type overrides it
}
```

## Standard protocols you'll use daily

| Protocol | Gives you |
|---|---|
| `Equatable` | `==` |
| `Hashable` | Use in `Set` and as `Dictionary` keys |
| `Comparable` | `<`, `sorted()` |
| `Codable` | JSON encoding and decoding |
| `Identifiable` | An `id` (SwiftUI lists) |
| `CustomStringConvertible` | A nice `description` for print |
| `Sendable` | Safe to share across concurrency domains |

```swift
struct Book: Hashable, Codable, Identifiable {   // conformances synthesized automatically
    let id: UUID
    var title: String
}
```

:::tip
**Protocol-oriented programming**: compose small protocols plus extensions instead of building deep class hierarchies.
:::

```quiz
[
 {"q": "What does a protocol define?", "options": ["Storage", "Requirements a type must implement", "A base class", "A module"], "answer": 1, "why": "Protocols are contracts; conforming types implement them."},
 {"q": "Which protocol is needed to use a type as a Dictionary key?", "options": ["Equatable", "Hashable", "Codable", "Comparable"], "answer": 1, "why": "Keys must be Hashable."}
]
```
