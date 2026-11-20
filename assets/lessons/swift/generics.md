---
title: Generics
summary: Write flexible, reusable, type-safe code.
minutes: 9
---
```swift
func swapValues<T>(_ a: inout T, _ b: inout T) {
    (a, b) = (b, a)
}

struct Stack<Element> {
    private var items: [Element] = []
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }
    var top: Element? { items.last }
}

var stack = Stack<String>()
stack.push("Swift")
```

## Constraints

```swift
func largest<T: Comparable>(_ items: [T]) -> T? {
    items.max()
}

func printAll<C: Collection>(_ c: C) where C.Element: CustomStringConvertible {
    for item in c { print(item.description) }
}
```

## some vs any

```swift
// some: "one specific concrete type, hidden from the caller" (opaque type)
func makeShape() -> some Shape { Circle(radius: 2) }

// any: "a box that can hold any type conforming to Shape" (existential)
var anything: any Shape = Circle(radius: 1)
anything = Square(side: 2)
```

| | `some Shape` | `any Shape` |
|---|---|---|
| Concrete type | One fixed type | Can change |
| Performance | Fast (static) | Small overhead (boxing) |
| Use for | Return types, parameters | Heterogeneous collections |

:::tip
Prefer `some` (and plain generics). Use `any` when you genuinely need to mix different types, like `[any Shape]`.
:::

```quiz
[
 {"q": "What does <T: Comparable> mean?", "options": ["T must be a class", "T can be any type that conforms to Comparable", "T is optional", "T is a String"], "answer": 1, "why": "It's a generic constraint."},
 {"q": "Which is best for a heterogeneous array of shapes?", "options": ["[some Shape]", "[any Shape]", "[Shape.Type]", "[T]"], "answer": 1, "why": "any lets each element be a different concrete type."}
]
```
