---
title: Control Flow
summary: if, switch, loops, and Swift's powerful pattern matching.
minutes: 9
---
## if / else (also as an expression)

```swift
let temp = 31
if temp > 30 {
    print("Hot")
} else if temp > 18 {
    print("Nice")
} else {
    print("Cold")
}

// if as an expression
let advice = if temp > 30 { "Drink water" } else { "Enjoy" }
```

## switch: must be exhaustive

```swift
let grade = 82
switch grade {
case 90...100: print("A")
case 80..<90:  print("B")
case 70..<80:  print("C")
default:       print("Keep practising")
}

let point = (0, 5)
switch point {
case (0, 0):           print("Origin")
case (0, let y):       print("On the y-axis at \(y)")
case let (x, y) where x == y: print("Diagonal")
default:               print("Somewhere else")
}
```

No `break` needed: Swift never falls through by accident.

## Loops

```swift
for fruit in ["apple", "mango"] { print(fruit) }

for (index, fruit) in ["apple", "mango"].enumerated() {
    print("\(index): \(fruit)")
}

for i in stride(from: 10, to: 0, by: -2) { print(i) }   // 10 8 6 4 2

var lives = 3
while lives > 0 { lives -= 1 }

repeat {
    print("runs at least once")
} while false
```

## continue, break and labels

```swift
outer: for row in 1...3 {
    for col in 1...3 {
        if col == 2 { continue }
        if row == 3 { break outer }
        print(row, col)
    }
}
```

```quiz
[
 {"q": "Must a Swift switch be exhaustive?", "options": ["No", "Yes: cover every case or add default", "Only for enums", "Only for Ints"], "answer": 1, "why": "The compiler requires every possible value to be handled."},
 {"q": "Does a Swift switch case fall through to the next by default?", "options": ["Yes", "No", "Only without break", "Only for strings"], "answer": 1, "why": "Use the fallthrough keyword if you really need it."}
]
```
