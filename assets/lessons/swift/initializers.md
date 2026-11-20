---
title: Initializers
summary: Memberwise, custom, failable and convenience inits.
minutes: 8
---
Every stored property must have a value before an instance can be used. Initializers guarantee that.

```swift
struct Email {
    let address: String

    // Failable initializer: returns nil for invalid input
    init?(_ raw: String) {
        guard raw.contains("@"), raw.contains(".") else { return nil }
        address = raw.lowercased()
    }
}

let ok = Email("Ada@Example.com")   // Email?
let bad = Email("nope")             // nil
```

## Keeping the memberwise init

Writing an init inside a struct removes the free memberwise one. Put custom inits in an **extension** to keep both:

```swift
struct Point { var x = 0.0, y = 0.0 }
extension Point {
    init(both v: Double) { self.init(x: v, y: v) }
}
Point(x: 1, y: 2); Point(both: 5)
```

## Class inits: designated & convenience

```swift
class Profile {
    let name: String
    let bio: String

    init(name: String, bio: String) {      // designated
        self.name = name
        self.bio = bio
    }

    convenience init(name: String) {       // must call another init of the same class
        self.init(name: name, bio: "")
    }
}
```

:::note
Subclasses initialize their **own** properties first, then call `super.init`. This "two-phase initialization" guarantees no property is ever read before it's set.
:::

```quiz
[
 {"q": "What does a failable initializer return?", "options": ["The type", "An optional of the type", "An error", "Bool"], "answer": 1, "why": "init? produces Type?."},
 {"q": "How do you keep a struct's memberwise init and add a custom one?", "options": ["You can't", "Put the custom init in an extension", "Mark it convenience", "Use a class"], "answer": 1, "why": "Inits declared in extensions don't remove the synthesized memberwise init."}
]
```
