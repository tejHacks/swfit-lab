---
title: Closures
summary: Functions as values, trailing closures and capture.
minutes: 9
---
A **closure** is a block of code you can store and pass around, like a function without a name.

```swift
let add = { (a: Int, b: Int) -> Int in
    a + b
}
add(2, 3)   // 5
```

## Shorter and shorter

```swift
let numbers = [5, 2, 9]
numbers.sorted(by: { (a: Int, b: Int) -> Bool in return a < b })
numbers.sorted(by: { a, b in a < b })   // types inferred
numbers.sorted { $0 < $1 }              // shorthand arguments + trailing closure
numbers.sorted(by: <)                   // operator as a function
```

## Trailing closures

If the last argument is a closure, write it after the parentheses. SwiftUI uses this everywhere:

```swift
Button("Save") {
    save()
}

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    print("One second later")
}
```

## Capturing values

```swift
func makeCounter() -> () -> Int {
    var count = 0
    return {
        count += 1      // the closure captures and keeps `count`
        return count
    }
}
let next = makeCounter()
next()   // 1
next()   // 2
```

## @escaping

A closure that's stored and called **after** the function returns must be marked `@escaping`:

```swift
var handlers: [() -> Void] = []
func onFinish(_ handler: @escaping () -> Void) {
    handlers.append(handler)
}
```

:::warning
Escaping closures in classes can create **retain cycles**. Capture `[weak self]` when a closure stored by `self` refers back to `self` (see the Memory lesson).
:::

```quiz
[
 {"q": "What is $0 in { $0 < $1 }?", "options": ["A global variable", "The first closure argument", "Zero", "The return value"], "answer": 1, "why": "$0, $1... are shorthand argument names."},
 {"q": "When must a closure parameter be @escaping?", "options": ["Always", "When it's stored or called after the function returns", "When it returns a value", "Never in Swift 6"], "answer": 1, "why": "Escaping closures outlive the function call."}
]
```
