---
title: Property Wrappers & Result Builders
summary: The magic behind @State and SwiftUI's view syntax.
minutes: 8
---
## Property wrappers

A property wrapper reuses get/set logic. `@State`, `@AppStorage` and `@Environment` are all property wrappers.

```swift
@propertyWrapper
struct Clamped {
    private var value: Int
    let range: ClosedRange<Int>

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
}

struct Volume {
    @Clamped(0...100) var level = 50
}

var v = Volume()
v.level = 150
print(v.level)   // 100
```

## Result builders

SwiftUI's `body` is a **result builder** (`@ViewBuilder`): it turns a list of expressions into one value.

```swift
@resultBuilder
struct ListBuilder {
    static func buildBlock(_ parts: String...) -> [String] { parts }
}

func makeList(@ListBuilder _ content: () -> [String]) -> [String] { content() }

let items = makeList {
    "Apples"
    "Bananas"
    "Cherries"
}
```

```swift
@ViewBuilder
func badge(for count: Int) -> some View {
    if count > 0 {
        Text("\(count)").padding(6).background(.red, in: .circle)
    } else {
        EmptyView()
    }
}
```

```quiz
[
 {"q": "Which property must a @propertyWrapper provide?", "options": ["value", "wrappedValue", "projectedValue", "storage"], "answer": 1, "why": "wrappedValue is required; projectedValue ($) is optional."},
 {"q": "What lets SwiftUI's body list several views without commas or return?", "options": ["Macros", "Result builders (@ViewBuilder)", "Closures only", "Generics"], "answer": 1, "why": "Result builders transform the statement list."}
]
```
