---
title: Optionals
summary: Swift's way of saying "there might be no value", safely.
minutes: 10
---
An **optional** either holds a value or holds `nil` (no value). You write it with `?`.

```swift
var middleName: String? = nil
middleName = "Grace"

let ageText = "34"
let age: Int? = Int(ageText)   // could fail, so it's optional
```

:::analogy
An optional is a gift box. Before using what's inside, you must open it and check it isn't empty.
:::

## Unwrapping safely

```swift
// 1. if let
if let age {
    print("Age is \(age)")
} else {
    print("No age")
}

// 2. guard let: exit early, keep the happy path un-indented
func greet(_ name: String?) {
    guard let name else {
        print("Who are you?")
        return
    }
    print("Hello, \(name)!")
}

// 3. nil-coalescing: a default value
let displayName = middleName ?? "none"

// 4. optional chaining: stops at the first nil
let count = middleName?.count          // Int?
let upper = user?.address?.city?.uppercased()
```

## Force unwrapping `!`

```swift
let url = URL(string: "https://swift.org")!   // OK only when it can't fail
```

:::warning
If a force-unwrapped optional is `nil`, your app **crashes**. Prefer `if let`, `guard let` or `??`. Reserve `!` for values that genuinely can't be nil.
:::

## Optionals of collections

```swift
let numbers = [3, 1, 2]
numbers.first        // Int? because the array might be empty
numbers.max() ?? 0
```

```quiz
[
 {"q": "What does `guard let` do if the value is nil?", "options": ["Crashes", "Runs the else block, which must exit the scope", "Continues normally", "Returns nil automatically"], "answer": 1, "why": "guard's else must leave the scope (return, throw, break...)."},
 {"q": "What is user?.address?.city if address is nil?", "options": ["Crash", "nil", "Empty string", "An error"], "answer": 1, "why": "Optional chaining returns nil as soon as a link is nil."},
 {"q": "When is ! (force unwrap) acceptable?", "options": ["Always", "When the value genuinely can never be nil", "Never", "Only in tests"], "answer": 1, "why": "Force unwrapping a nil crashes the app."}
]
```
