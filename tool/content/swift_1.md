=== FILE: what-is-swift.md ===
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

=== FILE: setup-xcode.md ===
---
title: Setting Up: Xcode & Playgrounds
summary: Install Xcode, run code instantly in Playgrounds, and create your first app.
minutes: 7
---
## Install Xcode

1. Open the **Mac App Store**, search **Xcode**, install it (it's large: be patient).
2. Open Xcode once so it can install extra components.
3. Optional: install the command-line tools with `xcode-select --install`.

## Three ways to run Swift

**1. Playgrounds:** the fastest way to learn. In Xcode choose **File → New → Playground**. Code runs as you type and results appear in the sidebar.

**2. Terminal:**

```bash
swift --version
echo 'print("Hello from the terminal!")' > hello.swift
swift hello.swift
```

**3. An iOS app:** **File → New → Project → iOS → App**, choose **SwiftUI**, then press **⌘R** to run it in the iPhone Simulator.

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, SwiftUI!")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    ContentView()
}
```

:::tip
`#Preview` shows a live preview of your view in Xcode's canvas. Press **⌥⌘↩** (Option + Command + Return) to show or hide it.
:::

## Useful shortcuts

| Shortcut | Action |
|---|---|
| ⌘R | Build & run |
| ⌘B | Build only |
| ⌘. | Stop |
| ⌘U | Run tests |
| ⌃I | Re-indent selection |
| ⌘/ | Comment / uncomment |
| ⇧⌘O | Open quickly (find any file) |

```quiz
[
 {"q": "What is the quickest way to experiment with Swift code?", "options": ["A full iOS project", "A Playground", "Terminal only", "TestFlight"], "answer": 1, "why": "Playgrounds run your code instantly as you type."},
 {"q": "Which shortcut builds and runs an app in Xcode?", "options": ["⌘B", "⌘R", "⌘U", "⌘P"], "answer": 1, "why": "⌘R builds and runs."}
]
```

=== FILE: first-program.md ===
---
title: Your First Swift Program
summary: print, comments, and how Swift code is structured.
minutes: 5
---
```swift
print("Hello, Swift!")
print("I am learning", "Swift", separator: " ✨ ")
```

- `print(...)` writes text to the console.
- Swift needs **no semicolons** at the end of lines (you can use them to put two statements on one line).
- In a Playground or script, top-level code runs from top to bottom. In apps, code runs from an entry point marked `@main`.

## Comments

```swift
// A single-line comment

/* A multi-line
   comment */

/// A documentation comment: shows up in Xcode's Quick Help (⌥-click).
func greet() {}
```

## String interpolation

Put values inside text with `\( )`:

```swift
let name = "Ada"
let age = 36
print("\(name) is \(age) years old. Next year she'll be \(age + 1).")
```

:::tip
Practise every example yourself in a Playground. Typing code (not copy-pasting) is how it sticks.
:::

```quiz
[
 {"q": "How do you insert a value into a string in Swift?", "options": ["${value}", "\\(value)", "{value}", "%value"], "answer": 1, "why": "Swift uses \\( ) for string interpolation."},
 {"q": "Do Swift statements need semicolons?", "options": ["Always", "No, only to separate statements on one line", "Only in classes", "Only in playgrounds"], "answer": 1, "why": "Semicolons are optional in Swift."}
]
```

=== FILE: variables-constants.md ===
---
title: Variables & Constants
summary: let vs var, naming, and why constants are preferred.
minutes: 6
---
```swift
let birthYear = 1990     // constant: can never change
var score = 0            // variable: can change
score += 10
// birthYear = 1991      // ❌ error: cannot assign to a 'let' constant
```

## let first

Use `let` by default and only switch to `var` when the value really must change. Constants make code easier to reason about, and Xcode warns you when a `var` is never changed.

## Type annotations

Swift **infers** types, but you can write them:

```swift
let name: String = "Ada"
var temperature: Double = 21.5
let isOnline: Bool
isOnline = true   // a constant can be assigned once, later
```

## Naming

- `camelCase` for variables, constants and functions: `userName`, `maxRetryCount`.
- `UpperCamelCase` for types: `UserProfile`, `NetworkError`.
- Clear names beat short names: `elapsedSeconds` instead of `t`.

```swift
let 🍕 = "pizza"   // Unicode names work, but please don't 😄
```

```quiz
[
 {"q": "Which keyword declares a constant?", "options": ["var", "let", "const", "final"], "answer": 1, "why": "let declares an immutable value."},
 {"q": "What does Swift recommend by default?", "options": ["var everywhere", "let unless the value must change", "global variables", "implicit types only"], "answer": 1, "why": "Prefer let; use var only when needed."}
]
```

=== FILE: types-and-inference.md ===
---
title: Basic Types & Type Safety
summary: Int, Double, Bool, String, Character, and converting between them.
minutes: 7
---
```swift
let age: Int = 30              // whole numbers
let price: Double = 19.99      // 64-bit decimal (preferred)
let ratio: Float = 0.5         // 32-bit decimal
let isAdmin: Bool = false
let initial: Character = "A"
let city: String = "Lagos"
```

## Type safety

Swift never mixes types silently. You must convert explicitly:

```swift
let apples = 3
let pricePerApple = 0.5
// let total = apples * pricePerApple        // ❌ Int * Double
let total = Double(apples) * pricePerApple   // ✅ 1.5

let input = "42"
let number = Int(input)        // Int? because "abc" can't become a number
print(number ?? 0)
```

## Number helpers

```swift
let big = 1_000_000           // underscores for readability
Int.max                       // 9223372036854775807
let rounded = (2.567).rounded()           // 3.0
let formatted = 3.14159.formatted(.number.precision(.fractionLength(2)))  // "3.14"
```

## Type aliases

```swift
typealias Kilometers = Double
let distance: Kilometers = 12.5
```

:::warning
Integer overflow crashes in Swift instead of silently wrapping. `Int.max + 1` traps at runtime. Use `&+` when you really want wrap-around.
:::

```quiz
[
 {"q": "What type does Int(\"abc\") return?", "options": ["Int", "Int? (nil here)", "String", "It crashes"], "answer": 1, "why": "Converting a string may fail, so the result is optional."},
 {"q": "How do you multiply an Int by a Double?", "options": ["Just multiply", "Convert one explicitly, e.g. Double(x)", "Use *.", "You can't"], "answer": 1, "why": "Swift requires explicit conversions between numeric types."}
]
```

=== FILE: operators.md ===
---
title: Operators
summary: Arithmetic, comparison, logic, ranges and the ternary operator.
minutes: 6
---
```swift
// Arithmetic
7 + 2      // 9
7 / 2      // 3   (Int division)
7.0 / 2    // 3.5
7 % 2      // 1   (remainder)

// Compound assignment
var hp = 100
hp -= 30   // 70

// Comparison: returns Bool
5 == 5; 5 != 3; 4 < 9; "apple" < "banana"

// Logic
let canDrive = age >= 18 && hasLicense
let isWeekend = day == "Sat" || day == "Sun"
let isClosed = !isOpen
```

## Ranges

```swift
for i in 1...5 { print(i) }     // closed: 1, 2, 3, 4, 5
for i in 0..<3 { print(i) }     // half-open: 0, 1, 2

let scores = [90, 72, 88, 64]
scores[1...]                     // one-sided: [72, 88, 64]
(1...10).contains(7)             // true
```

## Ternary and nil-coalescing

```swift
let label = score >= 50 ? "Pass" : "Fail"
let nickname: String? = nil
let shown = nickname ?? "Anonymous"
```

:::note
Swift has no `++` or `--` operators. Use `+= 1`.
:::

```quiz
[
 {"q": "What does 0..<3 contain?", "options": ["0,1,2,3", "0,1,2", "1,2,3", "3"], "answer": 1, "why": "Half-open ranges exclude the upper bound."},
 {"q": "Does Swift support i++?", "options": ["Yes", "No, use i += 1", "Only in loops", "Only for Int"], "answer": 1, "why": "++ and -- were removed in Swift 3."}
]
```

=== FILE: strings.md ===
---
title: Strings & Characters
summary: Working with text, multi-line strings and Unicode.
minutes: 7
---
```swift
var greeting = "Hello"
greeting += ", world"
greeting.append("!")

greeting.count                 // 13
greeting.isEmpty               // false
greeting.uppercased()          // "HELLO, WORLD!"
greeting.contains("world")     // true
greeting.hasPrefix("Hell")     // true
greeting.replacingOccurrences(of: "world", with: "Swift")
greeting.split(separator: ",") // ["Hello", " world!"]
"  trim me  ".trimmingCharacters(in: .whitespaces)
```

## Multi-line strings

```swift
let poem = """
    Roses are red,
    Swift is fast,
    Optionals keep
    your crashes past.
    """
```

## Unicode-correct by design

```swift
let flag = "🇳🇬"
flag.count        // 1 (one visible character, though it's several Unicode scalars)

for ch in "Café" { print(ch) }   // C a f é
```

Because characters can have different sizes, you can't use `text[3]`. Use indices:

```swift
let word = "Swift"
let third = word[word.index(word.startIndex, offsetBy: 2)]   // "i"
let firstThree = String(word.prefix(3))                     // "Swi"
```

## Raw strings

```swift
let regexText = #"\d+ apples"#     // backslashes are literal
```

```quiz
[
 {"q": "What is \"🇳🇬\".count?", "options": ["1", "2", "4", "8"], "answer": 0, "why": "Swift counts user-visible characters (grapheme clusters)."},
 {"q": "Why can't you write text[3] on a Swift String?", "options": ["Strings are immutable", "Characters can have different sizes, so Swift uses String.Index", "It's slow", "Strings are arrays"], "answer": 1, "why": "Indices respect Unicode boundaries."}
]
```

=== FILE: optionals.md ===
---
title: Optionals
summary: Swift's way of saying "there might be no value", safely.
minutes: 10
---
An **optional** either holds a value or holds `nil` (no value). You write it with `?`.

```swift
var middleName: String? = nil
middleName = "Grace"

let ageText = "34"
let age: Int? = Int(ageText)   // could fail, so it's optional
```

:::analogy
An optional is a gift box. Before using what's inside, you must open it and check it isn't empty.
:::

## Unwrapping safely

```swift
// 1. if let
if let age {
    print("Age is \(age)")
} else {
    print("No age")
}

// 2. guard let: exit early, keep the happy path un-indented
func greet(_ name: String?) {
    guard let name else {
        print("Who are you?")
        return
    }
    print("Hello, \(name)!")
}

// 3. nil-coalescing: a default value
let displayName = middleName ?? "none"

// 4. optional chaining: stops at the first nil
let count = middleName?.count          // Int?
let upper = user?.address?.city?.uppercased()
```

## Force unwrapping `!`

```swift
let url = URL(string: "https://swift.org")!   // OK only when it can't fail
```

:::warning
If a force-unwrapped optional is `nil`, your app **crashes**. Prefer `if let`, `guard let` or `??`. Reserve `!` for values that genuinely can't be nil.
:::

## Optionals of collections

```swift
let numbers = [3, 1, 2]
numbers.first        // Int? because the array might be empty
numbers.max() ?? 0
```

```quiz
[
 {"q": "What does `guard let` do if the value is nil?", "options": ["Crashes", "Runs the else block, which must exit the scope", "Continues normally", "Returns nil automatically"], "answer": 1, "why": "guard's else must leave the scope (return, throw, break...)."},
 {"q": "What is user?.address?.city if address is nil?", "options": ["Crash", "nil", "Empty string", "An error"], "answer": 1, "why": "Optional chaining returns nil as soon as a link is nil."},
 {"q": "When is ! (force unwrap) acceptable?", "options": ["Always", "When the value genuinely can never be nil", "Never", "Only in tests"], "answer": 1, "why": "Force unwrapping a nil crashes the app."}
]
```

=== FILE: control-flow.md ===
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

=== FILE: arrays.md ===
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

=== FILE: dictionaries-sets.md ===
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

=== FILE: functions.md ===
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

=== FILE: closures.md ===
---
title: Closures
summary: Functions as values, trailing closures and capture.
minutes: 9
---
A **closure** is a block of code you can store and pass around, like a function without a name.

```swift
let add = { (a: Int, b: Int) -> Int in
    a + b
}
add(2, 3)   // 5
```

## Shorter and shorter

```swift
let numbers = [5, 2, 9]
numbers.sorted(by: { (a: Int, b: Int) -> Bool in return a < b })
numbers.sorted(by: { a, b in a < b })   // types inferred
numbers.sorted { $0 < $1 }              // shorthand arguments + trailing closure
numbers.sorted(by: <)                   // operator as a function
```

## Trailing closures

If the last argument is a closure, write it after the parentheses. SwiftUI uses this everywhere:

```swift
Button("Save") {
    save()
}

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    print("One second later")
}
```

## Capturing values

```swift
func makeCounter() -> () -> Int {
    var count = 0
    return {
        count += 1      // the closure captures and keeps `count`
        return count
    }
}
let next = makeCounter()
next()   // 1
next()   // 2
```

## @escaping

A closure that's stored and called **after** the function returns must be marked `@escaping`:

```swift
var handlers: [() -> Void] = []
func onFinish(_ handler: @escaping () -> Void) {
    handlers.append(handler)
}
```

:::warning
Escaping closures in classes can create **retain cycles**. Capture `[weak self]` when a closure stored by `self` refers back to `self` (see the Memory lesson).
:::

```quiz
[
 {"q": "What is $0 in { $0 < $1 }?", "options": ["A global variable", "The first closure argument", "Zero", "The return value"], "answer": 1, "why": "$0, $1... are shorthand argument names."},
 {"q": "When must a closure parameter be @escaping?", "options": ["Always", "When it's stored or called after the function returns", "When it returns a value", "Never in Swift 6"], "answer": 1, "why": "Escaping closures outlive the function call."}
]
```

=== FILE: higher-order-functions.md ===
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
