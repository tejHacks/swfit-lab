---
title: What is Swift?
summary: Apple's fast, safe, modern language, and what you can build with it.
minutes: 5
---
**Swift** is a modern programming language created by Apple in 2014. It is the main language for building apps for **iPhone, iPad, Mac, Apple Watch, Apple TV and Vision Pro**. It is open source, and also runs on Linux, Windows and servers.

## Why Swift?

- **Safe**: no null pointer crashes by accident. Values must be initialised, and *optionals* make "no value" explicit.
- **Fast**: compiled to native machine code.
- **Expressive**: clean syntax that reads almost like English.
- **Modern**: closures, generics, pattern matching, async/await, actors and macros built in.

```swift
let languages = ["Swift", "Kotlin", "Dart"]
for language in languages where language.hasPrefix("S") {
    print("\(language) is great for iOS!")
}
```

## What you'll build with it

| Framework | For |
|---|---|
| **SwiftUI** | Modern declarative UI on all Apple platforms |
| **UIKit** | The classic iOS UI framework (still widely used) |
| **SwiftData** | Saving data on the device |
| **Vapor** | Server-side web apps and APIs in Swift |

:::note
This course uses **Swift 6**, including its strict, data-race-safe concurrency. Everything up to the Concurrency module also works on older Swift 5 projects.
:::

:::analogy
If programming languages were cars, Swift is a modern electric car: quick, with lots of safety systems that stop you crashing, while still letting you drive fast.
:::

```quiz
[
 {"q": "Who created Swift?", "options": ["Google", "Apple", "Microsoft", "Meta"], "answer": 1, "why": "Apple introduced Swift in 2014."},
 {"q": "Which framework is Apple's modern declarative UI toolkit?", "options": ["UIKit", "SwiftUI", "Cocoa", "Core Data"], "answer": 1, "why": "SwiftUI describes UI declaratively and works across Apple platforms."},
 {"q": "Is Swift open source?", "options": ["Yes", "No", "Only on Mac", "Only for Apple employees"], "answer": 0, "why": "Swift is open source and runs on Linux and Windows too."}
]
```
