---
title: Classes & Inheritance
summary: Reference types, inheritance, overriding and deinit.
minutes: 9
---
```swift
class Vehicle {
    var speed = 0.0
    let wheels: Int

    init(wheels: Int) {               // classes need an explicit init
        self.wheels = wheels
    }

    func describe() -> String { "\(wheels) wheels at \(speed) km/h" }

    deinit { print("Vehicle freed") } // runs when the object is destroyed
}

class Bicycle: Vehicle {
    var hasBell = true

    init() { super.init(wheels: 2) }

    override func describe() -> String {
        "🚲 " + super.describe()
    }
}

let bike = Bicycle()
bike.speed = 18
print(bike.describe())
```

## Reference semantics

```swift
let a = Vehicle(wheels: 4)
let b = a          // same object, not a copy
b.speed = 100
print(a.speed)     // 100
a === b            // true: identical instance
```

## final

```swift
final class Logger { }   // can't be subclassed (and it's faster: static dispatch)
```

## Struct vs class

| | struct | class |
|---|---|---|
| Semantics | Value (copied) | Reference (shared) |
| Inheritance | No (use protocols) | Yes |
| Memberwise init | Yes | No |
| deinit | No | Yes |
| Thread safety | Easier | Needs care |

```quiz
[
 {"q": "let b = a (classes); b.speed = 100. What is a.speed?", "options": ["Unchanged", "100", "0", "Error"], "answer": 1, "why": "Both names point to the same object."},
 {"q": "What does `final` do on a class?", "options": ["Makes it immutable", "Prevents subclassing", "Makes it a singleton", "Removes deinit"], "answer": 1, "why": "final classes can't be inherited from."}
]
```
