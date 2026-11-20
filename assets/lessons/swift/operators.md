---
title: Operators
summary: Arithmetic, comparison, logic, ranges and the ternary operator.
minutes: 6
---
```swift
// Arithmetic
7 + 2      // 9
7 / 2      // 3   (Int division)
7.0 / 2    // 3.5
7 % 2      // 1   (remainder)

// Compound assignment
var hp = 100
hp -= 30   // 70

// Comparison: returns Bool
5 == 5; 5 != 3; 4 < 9; "apple" < "banana"

// Logic
let canDrive = age >= 18 && hasLicense
let isWeekend = day == "Sat" || day == "Sun"
let isClosed = !isOpen
```

## Ranges

```swift
for i in 1...5 { print(i) }     // closed: 1, 2, 3, 4, 5
for i in 0..<3 { print(i) }     // half-open: 0, 1, 2

let scores = [90, 72, 88, 64]
scores[1...]                     // one-sided: [72, 88, 64]
(1...10).contains(7)             // true
```

## Ternary and nil-coalescing

```swift
let label = score >= 50 ? "Pass" : "Fail"
let nickname: String? = nil
let shown = nickname ?? "Anonymous"
```

:::note
Swift has no `++` or `--` operators. Use `+= 1`.
:::

```quiz
[
 {"q": "What does 0..<3 contain?", "options": ["0,1,2,3", "0,1,2", "1,2,3", "3"], "answer": 1, "why": "Half-open ranges exclude the upper bound."},
 {"q": "Does Swift support i++?", "options": ["Yes", "No, use i += 1", "Only in loops", "Only for Int"], "answer": 1, "why": "++ and -- were removed in Swift 3."}
]
```
