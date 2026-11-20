---
title: Extensions
summary: Add functionality to any type, even ones you don't own.
minutes: 6
---
```swift
extension Int {
    var isEven: Bool { self % 2 == 0 }
    func times(_ action: () -> Void) {
        for _ in 0..<self { action() }
    }
}

4.isEven            // true
3.times { print("Hip hip hooray!") }

extension String {
    var isValidEmail: Bool { contains("@") && contains(".") }
}
```

## Organising conformances

A common Swift style puts each protocol conformance in its own extension:

```swift
struct Product { let name: String; let price: Double }

extension Product: CustomStringConvertible {
    var description: String { "\(name): $\(price)" }
}

extension Product: Comparable {
    static func < (lhs: Product, rhs: Product) -> Bool { lhs.price < rhs.price }
}
```

## Constrained extensions

```swift
extension Array where Element == Int {
    var total: Int { reduce(0, +) }
}
[1, 2, 3].total   // 6
```

:::warning
Extensions can add methods, computed properties, inits and conformances, but **not stored properties**.
:::

```quiz
[
 {"q": "Can an extension add a stored property?", "options": ["Yes", "No, only computed ones", "Only to structs", "Only to classes"], "answer": 1, "why": "Extensions can't change a type's memory layout."}
]
```
