=== FILE: structs.md ===
---
title: Structs
summary: Your own value types with properties and methods.
minutes: 8
---
```swift
struct User {
    let id: Int
    var name: String
    var isPremium = false             // default value

    func greeting() -> String {
        "Hi, \(name)!"
    }

    mutating func upgrade() {         // methods that change self need `mutating`
        isPremium = true
    }
}

var ada = User(id: 1, name: "Ada")    // free memberwise initializer
ada.upgrade()
print(ada.greeting(), ada.isPremium)
```

## Value semantics

```swift
var copy = ada
copy.name = "Grace"
print(ada.name)    // "Ada": structs are copied
```

Each variable owns its **own** copy, so code elsewhere can't change your value behind your back.

## Static members

```swift
struct Temperature {
    static let freezing = 0.0
    var celsius: Double
}
Temperature.freezing
```

:::tip
Apple's guidance: **use structs by default**. Reach for classes when you need identity, inheritance or shared mutable state.
:::

```quiz
[
 {"q": "Why does a struct method that changes properties need `mutating`?", "options": ["Style", "Structs are value types; changing self must be explicit", "For speed", "It doesn't"], "answer": 1, "why": "mutating marks methods that modify the value."},
 {"q": "var b = a (structs); b.name = \"X\". What is a.name?", "options": ["X", "Unchanged", "nil", "Error"], "answer": 1, "why": "Structs are copied on assignment."}
]
```

=== FILE: classes.md ===
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

=== FILE: enums.md ===
---
title: Enums
summary: Cases, raw values, associated values and methods.
minutes: 9
---
```swift
enum Direction {
    case north, south, east, west
}

var heading = Direction.north
heading = .east           // type inferred

switch heading {
case .north: print("Up")
case .south: print("Down")
case .east, .west: print("Sideways")
}
```

## Raw values

```swift
enum Planet: Int, CaseIterable {
    case mercury = 1, venus, earth, mars
}
Planet.earth.rawValue          // 3
Planet(rawValue: 4)            // .mars (optional: might not exist)
Planet.allCases.count          // 4

enum HTTPMethod: String { case get = "GET", post = "POST" }
```

## Associated values: data per case

```swift
enum PaymentResult {
    case success(transactionID: String)
    case failure(reason: String, retryable: Bool)
    case pending
}

func handle(_ result: PaymentResult) {
    switch result {
    case .success(let id):
        print("Paid! \(id)")
    case .failure(let reason, retryable: true):
        print("Try again: \(reason)")
    case .failure(let reason, _):
        print("Failed: \(reason)")
    case .pending:
        print("Waiting…")
    }
}
```

## Methods and computed properties

```swift
enum Theme: String, CaseIterable {
    case light, dark, system
    var title: String { rawValue.capitalized }
}
```

:::tip
Enums with associated values are perfect for **states**: `enum LoadState { case idle, loading, loaded([Item]), failed(Error) }`. The compiler forces you to handle every state.
:::

```quiz
[
 {"q": "What does Planet(rawValue: 9) return if there's no case 9?", "options": ["Crash", "nil", "mercury", "0"], "answer": 1, "why": "Failable init from raw value returns an optional."},
 {"q": "Which protocol gives you allCases?", "options": ["Equatable", "CaseIterable", "Codable", "Hashable"], "answer": 1, "why": "CaseIterable synthesizes allCases."}
]
```

=== FILE: properties.md ===
---
title: Properties: Computed, Observers & Lazy
summary: More than stored values.
minutes: 8
---
## Computed properties

```swift
struct Rectangle {
    var width: Double
    var height: Double

    var area: Double { width * height }        // read-only computed

    var square: Bool {
        get { width == height }
    }
}
```

## Property observers

```swift
struct Account {
    var balance: Double = 0 {
        willSet { print("About to change to \(newValue)") }
        didSet {
            if balance < 0 { print("⚠️ Overdrawn by \(-balance)") }
        }
    }
}
```

## lazy

```swift
final class ReportScreen {
    lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()   // created only the first time it's used
}
```

## Access to setters

```swift
struct Counter {
    private(set) var value = 0      // readable outside, writable only inside
    mutating func increment() { value += 1 }
}
```

```quiz
[
 {"q": "When does didSet run?", "options": ["Before the change", "After the change", "On init", "Never for structs"], "answer": 1, "why": "didSet runs right after the new value is stored (not during init)."},
 {"q": "What does `lazy` mean?", "options": ["Thread-safe", "Computed on first access", "Read-only", "Static"], "answer": 1, "why": "Lazy properties are initialized when first used."}
]
```

=== FILE: initializers.md ===
---
title: Initializers
summary: Memberwise, custom, failable and convenience inits.
minutes: 8
---
Every stored property must have a value before an instance can be used. Initializers guarantee that.

```swift
struct Email {
    let address: String

    // Failable initializer: returns nil for invalid input
    init?(_ raw: String) {
        guard raw.contains("@"), raw.contains(".") else { return nil }
        address = raw.lowercased()
    }
}

let ok = Email("Ada@Example.com")   // Email?
let bad = Email("nope")             // nil
```

## Keeping the memberwise init

Writing an init inside a struct removes the free memberwise one. Put custom inits in an **extension** to keep both:

```swift
struct Point { var x = 0.0, y = 0.0 }
extension Point {
    init(both v: Double) { self.init(x: v, y: v) }
}
Point(x: 1, y: 2); Point(both: 5)
```

## Class inits: designated & convenience

```swift
class Profile {
    let name: String
    let bio: String

    init(name: String, bio: String) {      // designated
        self.name = name
        self.bio = bio
    }

    convenience init(name: String) {       // must call another init of the same class
        self.init(name: name, bio: "")
    }
}
```

:::note
Subclasses initialize their **own** properties first, then call `super.init`. This "two-phase initialization" guarantees no property is ever read before it's set.
:::

```quiz
[
 {"q": "What does a failable initializer return?", "options": ["The type", "An optional of the type", "An error", "Bool"], "answer": 1, "why": "init? produces Type?."},
 {"q": "How do you keep a struct's memberwise init and add a custom one?", "options": ["You can't", "Put the custom init in an extension", "Mark it convenience", "Use a class"], "answer": 1, "why": "Inits declared in extensions don't remove the synthesized memberwise init."}
]
```

=== FILE: protocols.md ===
---
title: Protocols
summary: Define capabilities; the heart of Swift's design.
minutes: 10
---
A **protocol** describes what a type can do, without saying how. Types **conform** by implementing the requirements.

```swift
protocol Shape {
    var area: Double { get }
    func describe() -> String
}

struct Circle: Shape {
    var radius: Double
    var area: Double { .pi * radius * radius }
    func describe() -> String { "Circle with area \(area.formatted())" }
}

struct Square: Shape {
    var side: Double
    var area: Double { side * side }
    func describe() -> String { "Square \(side)×\(side)" }
}

let shapes: [any Shape] = [Circle(radius: 1), Square(side: 3)]
for s in shapes { print(s.describe()) }
```

## Default implementations with extensions

```swift
extension Shape {
    func describe() -> String { "A shape with area \(area)" }   // used unless the type overrides it
}
```

## Standard protocols you'll use daily

| Protocol | Gives you |
|---|---|
| `Equatable` | `==` |
| `Hashable` | Use in `Set` and as `Dictionary` keys |
| `Comparable` | `<`, `sorted()` |
| `Codable` | JSON encoding and decoding |
| `Identifiable` | An `id` (SwiftUI lists) |
| `CustomStringConvertible` | A nice `description` for print |
| `Sendable` | Safe to share across concurrency domains |

```swift
struct Book: Hashable, Codable, Identifiable {   // conformances synthesized automatically
    let id: UUID
    var title: String
}
```

:::tip
**Protocol-oriented programming**: compose small protocols plus extensions instead of building deep class hierarchies.
:::

```quiz
[
 {"q": "What does a protocol define?", "options": ["Storage", "Requirements a type must implement", "A base class", "A module"], "answer": 1, "why": "Protocols are contracts; conforming types implement them."},
 {"q": "Which protocol is needed to use a type as a Dictionary key?", "options": ["Equatable", "Hashable", "Codable", "Comparable"], "answer": 1, "why": "Keys must be Hashable."}
]
```

=== FILE: extensions.md ===
---
title: Extensions
summary: Add functionality to any type, even ones you don't own.
minutes: 6
---
```swift
extension Int {
    var isEven: Bool { self % 2 == 0 }
    func times(_ action: () -> Void) {
        for _ in 0..<self { action() }
    }
}

4.isEven            // true
3.times { print("Hip hip hooray!") }

extension String {
    var isValidEmail: Bool { contains("@") && contains(".") }
}
```

## Organising conformances

A common Swift style puts each protocol conformance in its own extension:

```swift
struct Product { let name: String; let price: Double }

extension Product: CustomStringConvertible {
    var description: String { "\(name): $\(price)" }
}

extension Product: Comparable {
    static func < (lhs: Product, rhs: Product) -> Bool { lhs.price < rhs.price }
}
```

## Constrained extensions

```swift
extension Array where Element == Int {
    var total: Int { reduce(0, +) }
}
[1, 2, 3].total   // 6
```

:::warning
Extensions can add methods, computed properties, inits and conformances, but **not stored properties**.
:::

```quiz
[
 {"q": "Can an extension add a stored property?", "options": ["Yes", "No, only computed ones", "Only to structs", "Only to classes"], "answer": 1, "why": "Extensions can't change a type's memory layout."}
]
```

=== FILE: generics.md ===
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

=== FILE: error-handling.md ===
---
title: Error Handling
summary: throws, do/try/catch, typed throws and Result.
minutes: 9
---
```swift
enum WithdrawalError: Error {
    case insufficientFunds(needed: Double)
    case accountLocked
}

struct Account {
    var balance: Double
    var locked = false

    mutating func withdraw(_ amount: Double) throws {
        guard !locked else { throw WithdrawalError.accountLocked }
        guard amount <= balance else {
            throw WithdrawalError.insufficientFunds(needed: amount - balance)
        }
        balance -= amount
    }
}

var account = Account(balance: 50)
do {
    try account.withdraw(80)
} catch WithdrawalError.insufficientFunds(let needed) {
    print("You need \(needed) more")
} catch {
    print("Something else went wrong: \(error)")
}
```

## try? and try!

```swift
let data = try? Data(contentsOf: url)       // nil on failure
let config = try! loadBundledConfig()       // crash on failure: only if impossible
```

## Typed throws (Swift 6)

```swift
func parse(_ text: String) throws(ParseError) -> Int {
    guard let n = Int(text) else { throw .notANumber }
    return n
}

do {
    let n = try parse("x")
} catch {
    // `error` is ParseError here, not `any Error`
}
```

## Result

```swift
func fetchUser(id: Int) -> Result<User, NetworkError> { ... }

switch fetchUser(id: 1) {
case .success(let user): print(user.name)
case .failure(let error): print(error)
}
```

## defer

```swift
func process(file: FileHandle) throws {
    defer { try? file.close() }     // runs however the function exits
    // ...
}
```

```quiz
[
 {"q": "What does try? return when the call throws?", "options": ["Crashes", "nil", "The error", "false"], "answer": 1, "why": "try? converts errors into nil."},
 {"q": "What do typed throws (Swift 6) give you?", "options": ["Faster code only", "The catch block knows the exact error type", "No need for try", "Automatic retries"], "answer": 1, "why": "throws(MyError) makes the error type concrete."},
 {"q": "When does a defer block run?", "options": ["Immediately", "When the current scope exits", "Only on errors", "On app launch"], "answer": 1, "why": "defer runs on scope exit, however you leave."}
]
```

=== FILE: memory-arc.md ===
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

=== FILE: access-control.md ===
---
title: Access Control
summary: private, fileprivate, internal, package, public and open.
minutes: 6
---
| Level | Visible in |
|---|---|
| `private` | The enclosing declaration (and its extensions in the same file) |
| `fileprivate` | The whole file |
| `internal` *(default)* | The whole module (your app target) |
| `package` | Other modules in the same Swift package |
| `public` | Any module that imports yours |
| `open` | Like public, **plus** can be subclassed and overridden outside the module |

```swift
public struct BankAccount {
    public private(set) var balance: Double = 0   // read anywhere, write only inside
    private var history: [Double] = []

    public init() {}

    public mutating func deposit(_ amount: Double) {
        guard amount > 0 else { return }
        balance += amount
        history.append(amount)
    }
}
```

:::tip
Start everything as `private` and widen access only when something outside genuinely needs it. Small public surfaces are easier to change later.
:::

```quiz
[
 {"q": "What is Swift's default access level?", "options": ["private", "internal", "public", "open"], "answer": 1, "why": "internal: visible within the module."},
 {"q": "Which level allows subclassing from another module?", "options": ["public", "open", "internal", "package"], "answer": 1, "why": "Only open classes can be subclassed outside their module."}
]
```
