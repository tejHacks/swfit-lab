---
title: Basic Types & Type Safety
summary: Int, Double, Bool, String, Character, and converting between them.
minutes: 7
---
```swift
let age: Int = 30              // whole numbers
let price: Double = 19.99      // 64-bit decimal (preferred)
let ratio: Float = 0.5         // 32-bit decimal
let isAdmin: Bool = false
let initial: Character = "A"
let city: String = "Lagos"
```

## Type safety

Swift never mixes types silently. You must convert explicitly:

```swift
let apples = 3
let pricePerApple = 0.5
// let total = apples * pricePerApple        // ❌ Int * Double
let total = Double(apples) * pricePerApple   // ✅ 1.5

let input = "42"
let number = Int(input)        // Int? because "abc" can't become a number
print(number ?? 0)
```

## Number helpers

```swift
let big = 1_000_000           // underscores for readability
Int.max                       // 9223372036854775807
let rounded = (2.567).rounded()           // 3.0
let formatted = 3.14159.formatted(.number.precision(.fractionLength(2)))  // "3.14"
```

## Type aliases

```swift
typealias Kilometers = Double
let distance: Kilometers = 12.5
```

:::warning
Integer overflow crashes in Swift instead of silently wrapping. `Int.max + 1` traps at runtime. Use `&+` when you really want wrap-around.
:::

```quiz
[
 {"q": "What type does Int(\"abc\") return?", "options": ["Int", "Int? (nil here)", "String", "It crashes"], "answer": 1, "why": "Converting a string may fail, so the result is optional."},
 {"q": "How do you multiply an Int by a Double?", "options": ["Just multiply", "Convert one explicitly, e.g. Double(x)", "Use *.", "You can't"], "answer": 1, "why": "Swift requires explicit conversions between numeric types."}
]
```
