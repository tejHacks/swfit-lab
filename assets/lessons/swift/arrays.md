---
title: Arrays
summary: Ordered lists of values.
minutes: 7
---
```swift
var fruits = ["apple", "banana"]          // [String]
var scores: [Int] = []

fruits.append("cherry")
fruits += ["date"]
fruits.insert("avocado", at: 0)
fruits.remove(at: 1)
fruits[0] = "apricot"

fruits.count
fruits.isEmpty
fruits.first          // String?
fruits.contains("date")
fruits.firstIndex(of: "cherry")   // Int?
fruits.sorted()
fruits.reversed()
fruits.shuffled()
```

## Safe access

```swift
let numbers = [10, 20, 30]
// numbers[5]   // ❌ crash: Index out of range
if numbers.indices.contains(5) { print(numbers[5]) }
```

## Arrays are value types

```swift
var a = [1, 2, 3]
var b = a        // a copy (copy-on-write, so it's cheap)
b.append(4)
print(a)         // [1, 2, 3]: a is unchanged
```

```quiz
[
 {"q": "What happens when you access an index outside an array?", "options": ["Returns nil", "Runtime crash", "Returns 0", "Grows the array"], "answer": 1, "why": "Out-of-range subscripts trap at runtime."},
 {"q": "var b = a; b.append(4). Does a change?", "options": ["Yes", "No, arrays are value types", "Only if a is let", "Sometimes"], "answer": 1, "why": "Arrays are copied on assignment (copy-on-write)."}
]
```
