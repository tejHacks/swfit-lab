---
title: Dictionaries, Sets & Tuples
summary: Key-value lookups, unique collections and lightweight groups.
minutes: 7
---
## Dictionaries

```swift
var ages = ["Ada": 36, "Linus": 54]
ages["Grace"] = 85          // add or update
ages["Linus"] = nil         // remove

let adaAge = ages["Ada"]                  // Int? (the key may be missing)
let bobAge = ages["Bob", default: 0]      // 0

for (name, age) in ages.sorted(by: { $0.key < $1.key }) {
    print("\(name): \(age)")
}
ages.keys; ages.values
```

## Sets: unique, unordered

```swift
var tags: Set = ["swift", "ios"]
tags.insert("swift")      // ignored: already there
tags.contains("ios")      // very fast lookup

let a: Set = [1, 2, 3], b: Set = [2, 3, 4]
a.union(b)          // [1, 2, 3, 4]
a.intersection(b)   // [2, 3]
a.subtracting(b)    // [1]
```

## Tuples

```swift
let http404 = (code: 404, message: "Not Found")
print(http404.code, http404.message)

func minMax(_ values: [Int]) -> (min: Int, max: Int)? {
    guard let lo = values.min(), let hi = values.max() else { return nil }
    return (lo, hi)
}
```

```quiz
[
 {"q": "What type does ages[\"Bob\"] return?", "options": ["Int", "Int?", "String", "Bool"], "answer": 1, "why": "The key might not exist, so the result is optional."},
 {"q": "Which collection guarantees uniqueness?", "options": ["Array", "Dictionary values", "Set", "Tuple"], "answer": 2, "why": "Sets store each element at most once."}
]
```
