---
title: map, filter, reduce & Friends
summary: Transform collections declaratively.
minutes: 8
---
```swift
let prices = [12.5, 3.0, 40.0, 7.25]

let withTax = prices.map { $0 * 1.075 }           // transform each
let cheap = prices.filter { $0 < 10 }             // keep some
let total = prices.reduce(0, +)                   // combine into one
let expensive = prices.contains { $0 > 30 }       // any match?
let allPositive = prices.allSatisfy { $0 > 0 }
let firstBig = prices.first { $0 > 10 }           // Double?
let sortedDesc = prices.sorted(by: >)
```

## compactMap and flatMap

```swift
let inputs = ["1", "two", "3"]
let numbers = inputs.compactMap { Int($0) }       // [1, 3]: drops nils

let nested = [[1, 2], [3], [4, 5]]
let flat = nested.flatMap { $0 }                  // [1, 2, 3, 4, 5]
```

## Grouping and chaining

```swift
struct Order { let customer: String; let total: Double }
let orders = [
    Order(customer: "Ada", total: 120),
    Order(customer: "Tunde", total: 80),
    Order(customer: "Ada", total: 45),
]

let byCustomer = Dictionary(grouping: orders, by: \.customer)
let totals = byCustomer.mapValues { $0.reduce(0) { $0 + $1.total } }
// ["Ada": 165, "Tunde": 80]

let bigSpenders = orders
    .filter { $0.total > 50 }
    .map(\.customer)          // key path as a function
    .sorted()
```

:::tip
`\.customer` is a **key path**: a reference to a property. You can pass it wherever a closure like `{ $0.customer }` is expected.
:::

```quiz
[
 {"q": "Which method removes nils while transforming?", "options": ["map", "compactMap", "filter", "flatMap"], "answer": 1, "why": "compactMap transforms and discards nil results."},
 {"q": "What does reduce(0, +) compute on [1,2,3]?", "options": ["0", "6", "[1,2,3]", "3"], "answer": 1, "why": "It folds the values together with +, starting from 0."}
]
```
