---
title: Memory & ARC
summary: Automatic Reference Counting, retain cycles, weak and unowned.
minutes: 10
---
Swift manages class memory with **ARC (Automatic Reference Counting)**. Each class instance keeps a count of **strong references**. When the count reaches zero, it's freed and `deinit` runs.

```swift
class Person {
    let name: String
    init(name: String) { self.name = name }
    deinit { print("\(name) freed") }
}

var p: Person? = Person(name: "Ada")   // count = 1
p = nil                                // count = 0, so "Ada freed"
```

## Retain cycles: the classic leak

```swift
class Owner {
    var pet: Pet?
    deinit { print("Owner freed") }
}
class Pet {
    var owner: Owner?          // ❌ strong back-reference
    deinit { print("Pet freed") }
}

var o: Owner? = Owner()
var d: Pet? = Pet()
o?.pet = d
d?.owner = o
o = nil; d = nil               // nothing is printed: they keep each other alive (leak)
```

**Fix:** make the back-reference `weak`:

```swift
class Pet {
    weak var owner: Owner?     // doesn't increase the count; becomes nil when Owner is freed
}
```

## weak vs unowned

| | `weak` | `unowned` |
|---|---|---|
| Type | Always optional (`var x: T?`) | Non-optional |
| When the object dies | Becomes `nil` | Dangling: crash if accessed |
| Use when | The other object may die first | The other object always outlives this one |

## Closures capture strongly

```swift
final class Downloader {
    var onComplete: (() -> Void)?
    var progress = 0

    func start() {
        onComplete = { [weak self] in        // capture list
            guard let self else { return }
            print("Done at \(self.progress)%")
        }
    }
}
```

:::tip
Find leaks with Xcode's **Debug Memory Graph** button and with **Instruments → Leaks**.
:::

```quiz
[
 {"q": "What causes a retain cycle?", "options": ["Two structs referencing each other", "Two objects holding strong references to each other", "Using weak", "Using let"], "answer": 1, "why": "Strong references in both directions keep both alive."},
 {"q": "What happens to a weak reference when its object is deallocated?", "options": ["Crash", "It becomes nil", "It keeps the object alive", "It points to garbage"], "answer": 1, "why": "weak references are zeroed automatically."},
 {"q": "Does ARC apply to structs?", "options": ["Yes, the same way", "No, ARC is for class instances (reference types)", "Only in Swift 6", "Only for arrays"], "answer": 1, "why": "Value types aren't reference counted (though they may contain references)."}
]
```
