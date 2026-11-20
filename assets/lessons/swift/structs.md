---
title: Structs
summary: Your own value types with properties and methods.
minutes: 8
---
```swift
struct User {
    let id: Int
    var name: String
    var isPremium = false             // default value

    func greeting() -> String {
        "Hi, \(name)!"
    }

    mutating func upgrade() {         // methods that change self need `mutating`
        isPremium = true
    }
}

var ada = User(id: 1, name: "Ada")    // free memberwise initializer
ada.upgrade()
print(ada.greeting(), ada.isPremium)
```

## Value semantics

```swift
var copy = ada
copy.name = "Grace"
print(ada.name)    // "Ada": structs are copied
```

Each variable owns its **own** copy, so code elsewhere can't change your value behind your back.

## Static members

```swift
struct Temperature {
    static let freezing = 0.0
    var celsius: Double
}
Temperature.freezing
```

:::tip
Apple's guidance: **use structs by default**. Reach for classes when you need identity, inheritance or shared mutable state.
:::

```quiz
[
 {"q": "Why does a struct method that changes properties need `mutating`?", "options": ["Style", "Structs are value types; changing self must be explicit", "For speed", "It doesn't"], "answer": 1, "why": "mutating marks methods that modify the value."},
 {"q": "var b = a (structs); b.name = \"X\". What is a.name?", "options": ["X", "Unchanged", "nil", "Error"], "answer": 1, "why": "Structs are copied on assignment."}
]
```
