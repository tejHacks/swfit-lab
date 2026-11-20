---
title: Functions
summary: Parameters, labels, defaults, return values and inout.
minutes: 9
---
```swift
func greet(name: String) -> String {
    "Hello, \(name)!"           // single expressions return implicitly
}
greet(name: "Ada")
```

## Argument labels

```swift
// external label "to", internal name "person"
func sayHello(to person: String) { print("Hi \(person)") }
sayHello(to: "Linus")

// _ means no label at the call site
func square(_ x: Int) -> Int { x * x }
square(4)
```

## Defaults and variadics

```swift
func makeCoffee(size: String = "Medium", sugar: Int = 0) -> String {
    "\(size) coffee, \(sugar) sugar"
}
makeCoffee()
makeCoffee(sugar: 2)

func average(_ numbers: Double...) -> Double {
    numbers.isEmpty ? 0 : numbers.reduce(0, +) / Double(numbers.count)
}
average(3, 4, 5)
```

## Multiple returns and inout

```swift
func divide(_ a: Int, by b: Int) -> (quotient: Int, remainder: Int) {
    (a / b, a % b)
}
let result = divide(17, by: 5)   // (3, 2)

func double(_ value: inout Int) { value *= 2 }
var n = 21
double(&n)       // n is now 42
```

:::tip
Good Swift APIs read like sentences at the call site: `move(from: a, to: b)`, `insert(item, at: 0)`. Pick labels with that in mind.
:::

```quiz
[
 {"q": "What does `_` before a parameter name do?", "options": ["Makes it private", "Removes the argument label at the call site", "Makes it optional", "Makes it inout"], "answer": 1, "why": "Callers then write square(4) instead of square(x: 4)."},
 {"q": "How do you let a function modify a caller's variable?", "options": ["var parameter", "inout parameter, called with &", "static", "Return it"], "answer": 1, "why": "inout parameters are passed with & at the call site."}
]
```
