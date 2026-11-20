=== Q: let-vs-var | Swift Basics | beginner
What is the difference between `let` and `var`?
---
`let` declares a **constant**: it can be assigned once and never changed. `var` declares a **variable** that can be reassigned.

For value types (structs, enums, arrays), `let` also makes the whole value immutable: you can't call `mutating` methods or change properties. For a class instance, `let` only fixes the **reference**. The object's `var` properties can still change.

Best practice: use `let` by default and switch to `var` only when needed.

=== Q: type-inference | Swift Basics | beginner
What is type inference, and is Swift statically typed?
---
Swift is **statically typed**: every value's type is known at compile time. **Type inference** means the compiler works the type out from context, so you don't have to write it: `let count = 3` is an `Int`.

You can still annotate (`let price: Double = 3`) when you want a different type or extra clarity. Inference never makes code dynamic: types can't change at runtime.

=== Q: value-vs-reference | Swift Basics | beginner
Explain value types vs reference types, with examples.
---
- **Value types** (`struct`, `enum`, tuples, and the standard `Array`, `String`, `Dictionary`) are **copied** on assignment. Each copy is independent.
- **Reference types** (`class`, `actor`, closures) are **shared**: assigning copies a reference to the same instance.

```swift
struct P { var x = 0 }
var a = P(); var b = a; b.x = 9      // a.x is still 0

class C { var x = 0 }
let c1 = C(); let c2 = c1; c2.x = 9  // c1.x is now 9
```

Value types make code easier to reason about and are safer under concurrency. Swift collections use **copy-on-write**, so copies are cheap until one is modified.

=== Q: struct-vs-class | Types & Protocols | beginner
When would you choose a class over a struct?
---
Default to **structs**. Choose a **class** when you need:

- **Identity**: the same instance shared and observed from several places (for example a view model or a cache).
- **Inheritance** (also needed for UIKit subclasses like `UIViewController`).
- **deinit** to clean up resources.
- **Objective-C interop** (`@objc`, NSObject subclasses).

Also consider an **actor** when shared mutable state is accessed concurrently.

=== Q: optionals-what | Optionals | beginner
What is an optional, and how is it implemented?
---
An optional represents "a value **or** nothing". `String?` is shorthand for `Optional<String>`, which is just an enum:

```swift
enum Optional<Wrapped> {
    case none
    case some(Wrapped)
}
```

`nil` is `.none`. Because "no value" is a distinct type, the compiler forces you to handle it before use, which eliminates a whole class of null-pointer crashes.

=== Q: unwrapping | Optionals | beginner
What are the different ways to unwrap an optional? Which do you prefer?
---
1. `if let value { ... }`: optional binding.
2. `guard let value else { return }`: early exit; keeps the happy path un-indented.
3. `value ?? defaultValue`: nil-coalescing.
4. `value?.property`: optional chaining (the result is optional).
5. `switch` / pattern matching: `case .some(let v)`.
6. `value!`: force unwrap. It **crashes** if nil, so avoid it except for truly impossible cases.

Prefer `guard let` for preconditions and `if let` or `??` elsewhere.

=== Q: optional-chaining | Optionals | intermediate
What does `user?.address?.city?.count` return when `address` is nil?
---
It returns **`nil`**, typed `Int?`. Optional chaining stops evaluating at the first `nil` link and makes the whole expression optional, with no crash. Methods in the chain also return optionals, so `user?.logout()` returns `Void?` (`nil` if `user` was nil). That lets you check whether the call actually happened.

=== Q: implicitly-unwrapped | Optionals | intermediate
What is an implicitly unwrapped optional (`String!`) and when is it used?
---
It's an optional that is automatically force-unwrapped wherever it's used as a non-optional. If it's `nil` at that moment, the app crashes.

It exists for values that **can't be set in `init` but are guaranteed to be set before use**, most famously UIKit `@IBOutlet`s and some two-phase setups. In modern Swift, prefer real optionals, `lazy` properties or dependency injection through `init`.

=== Q: guard-vs-if | Swift Basics | beginner
What's the difference between `guard` and `if`?
---
`guard` checks a condition and **requires** its `else` branch to exit the scope (`return`, `throw`, `break`, `continue` or a `Never` call). Variables bound with `guard let` remain available **after** the guard, for the rest of the scope.

That makes guard ideal for validating preconditions at the top of a function and keeping the main logic un-nested ("early exit"). Use `if` when both branches continue normally.

=== Q: switch-exhaustive | Swift Basics | beginner
What's special about Swift's `switch` compared with C or Java?
---
- It must be **exhaustive**: every possible value must be handled (or use `default`).
- **No implicit fallthrough**, so no `break` is needed (use `fallthrough` explicitly).
- **Pattern matching**: ranges (`case 1...5`), tuples, `where` clauses, enum associated values (`case .failure(let error)`), type casts (`case let s as String`).
- It can be used as an **expression**: `let label = switch x { case 0: "zero" default: "other" }`.

=== Q: closures-capture | Swift Basics | intermediate
What is a closure and how does capturing work?
---
A closure is a self-contained block of code that can be passed around and called later. Functions are named closures.

Closures **capture** variables from their surrounding scope **by reference**, keeping them alive:

```swift
func counter() -> () -> Int {
    var n = 0
    return { n += 1; return n }
}
```

Use a **capture list** to capture by value or weakly: `{ [count] in ... }` copies the current value; `{ [weak self] in ... }` avoids retain cycles.

=== Q: escaping | Swift Basics | intermediate
What does `@escaping` mean?
---
A closure parameter is **non-escaping** by default: it's guaranteed to be called (if at all) before the function returns. Mark it `@escaping` when the closure may be **stored or called later**, such as a completion handler kept in a property or dispatched asynchronously.

Non-escaping closures can be optimised by the compiler and can use `self` implicitly. Escaping closures make you think about memory, because they may create retain cycles.

=== Q: higher-order | Swift Basics | beginner
Explain `map`, `compactMap`, `flatMap`, `filter` and `reduce`.
---
- `map`: transform each element → `[1,2].map { $0 * 2 }` = `[2,4]`
- `compactMap`: transform and **drop nils** → `["1","x"].compactMap { Int($0) }` = `[1]`
- `flatMap`: transform into sequences and **flatten** → `[[1],[2,3]].flatMap { $0 }` = `[1,2,3]`
- `filter`: keep elements matching a predicate
- `reduce`: combine everything into one value → `[1,2,3].reduce(0, +)` = `6`

On optionals, `map` and `flatMap` transform the wrapped value if present.

=== Q: protocols-what | Types & Protocols | beginner
What is a protocol, and what is protocol-oriented programming?
---
A protocol defines a **contract** of requirements (properties, methods, initializers) that conforming types must implement. Structs, enums, classes and actors can all conform.

**Protocol-oriented programming** means building behaviour by composing small protocols plus **protocol extensions** with default implementations, instead of deep class inheritance. You get shared behaviour for value types, easy testing (inject a protocol, pass a mock) and flexible composition (`Named & Priced`).

=== Q: protocol-extension-dispatch | Types & Protocols | advanced
A method is declared only in a protocol extension (not in the protocol). A conforming type implements it too. Which version is called through a variable of the protocol type?
---
The **extension's** version. Methods declared only in a protocol extension are **statically dispatched**: the call is resolved at compile time from the variable's static type.

```swift
protocol Greeter {}
extension Greeter { func hi() -> String { "extension" } }
struct English: Greeter { func hi() -> String { "type" } }

let g: any Greeter = English()
g.hi()                  // "extension"
English().hi()          // "type"
```

If `hi()` is declared **in the protocol** itself, it becomes a requirement, dispatched dynamically through the witness table, and the type's version wins.

=== Q: associated-types | Types & Protocols | intermediate
What is an associated type? Give an example.
---
An `associatedtype` is a placeholder type inside a protocol, filled in by each conforming type. It makes protocols generic.

```swift
protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
}
struct IntBox: Container { var items: [Int] = []
    mutating func append(_ item: Int) { items.append(item) }
    var count: Int { items.count } }
```

`Collection.Element` and `Sequence.Iterator` are associated types. With **primary associated types** (`protocol Container<Item>`), you can write `some Container<Int>`.

=== Q: some-vs-any | Types & Protocols | intermediate
What's the difference between `some Protocol` and `any Protocol`?
---
- `some P` is an **opaque type**: one specific concrete type, chosen by the implementation and hidden from the caller. The compiler knows it, so calls are statically dispatched and fast. SwiftUI's `var body: some View` is the classic example.
- `any P` is an **existential**: a box that can hold *any* conforming type, and the value inside can change at runtime. It has a small cost (boxing and dynamic dispatch).

Use `some` (or generics) by default. Use `any` when you need different concrete types together, such as `[any Shape]`.

=== Q: generics-why | Types & Protocols | intermediate
Why use generics? What are constraints?
---
Generics let you write **one** type-safe implementation that works for many types, with no duplication and no losing types to `Any`.

```swift
func firstDuplicate<T: Hashable>(_ items: [T]) -> T? {
    var seen = Set<T>()
    for item in items where !seen.insert(item).inserted { return item }
    return nil
}
```

**Constraints** (`T: Hashable`, `where T.Element: Equatable`) limit which types can be used, so you can call the required methods. Generic code is specialised by the compiler for performance.

=== Q: enums-associated | Types & Protocols | beginner
What are associated values in enums, and how are they different from raw values?
---
- **Raw values** are fixed constants of one type per case (`case get = "GET"`), the same for every instance. They're used for conversion (`init?(rawValue:)`).
- **Associated values** attach **different data to each instance** of a case: `case success(Data)`, `case failure(Error)`.

Associated values are ideal for modelling state (`enum Load { case loading, loaded([Item]), failed(Error) }`): the compiler forces you to handle every state, and impossible states can't be represented.

=== Q: mutating | Types & Protocols | beginner
Why do some struct methods need `mutating`?
---
Structs are value types and their methods get an immutable `self` by default. A method that changes properties (or reassigns `self`) must be marked `mutating`, so the change is explicit and so it can't be called on a `let` constant. Classes don't need it because `self` is a reference.

=== Q: computed-vs-stored | Types & Protocols | beginner
What is the difference between stored and computed properties? What are property observers?
---
- **Stored properties** hold a value in memory.
- **Computed properties** run code each time they're read (and optionally written). They don't store anything.

**Property observers** `willSet` / `didSet` run code before or after a stored property changes (not during `init`). They're useful for validation, side effects or syncing. `lazy` stored properties are created on first access.

=== Q: copy-on-write | Types & Protocols | advanced
What is copy-on-write and how would you implement it for a custom type?
---
Copy-on-write (COW) makes copies of large value types cheap: copies **share storage** until one of them is mutated, and only then is the storage duplicated. `Array`, `Dictionary`, `Set` and `String` use it.

Implement it with a class for storage plus `isKnownUniquelyReferenced`:

```swift
final class Storage { var values: [Int]; init(_ v: [Int]) { values = v } }

struct BigList {
    private var storage = Storage([])
    var values: [Int] { storage.values }

    mutating func append(_ v: Int) {
        if !isKnownUniquelyReferenced(&storage) {
            storage = Storage(storage.values)   // copy only when shared
        }
        storage.values.append(v)
    }
}
```

=== Q: arc | Memory | beginner
How does memory management work in Swift?
---
Swift uses **ARC (Automatic Reference Counting)** for class instances (and actors and closures). Each instance tracks how many **strong references** point to it. When the count drops to zero, `deinit` runs and the memory is freed immediately (there's no garbage-collector pause).

Value types (structs, enums) live inline or are managed through copy-on-write buffers. You don't manage them, but they can **contain** references that ARC counts.

=== Q: retain-cycle | Memory | intermediate
What is a retain cycle, and how do you fix one?
---
A retain cycle happens when two (or more) objects hold **strong** references to each other, so neither count reaches zero and both leak.

Common causes:
- parent ↔ child references (a delegate or owner back-pointer)
- closures stored by an object that capture `self`

Fixes:
- make one side `weak` (it becomes nil when the target dies) or `unowned`
- use a capture list in closures: `{ [weak self] in guard let self else { return } ... }`

Detect leaks with Xcode's **Memory Graph Debugger** and **Instruments → Leaks**.

=== Q: weak-vs-unowned | Memory | intermediate
What's the difference between `weak` and `unowned`?
---
Both create references that don't increase the retain count.

- `weak`: always an **optional `var`**; automatically set to `nil` when the object is deallocated. Use it when the referenced object may die first (delegates, parent references).
- `unowned`: **non-optional**. Accessing it after the object is gone **crashes**. Use it only when the other object is guaranteed to outlive this one (for example a credit card that always has a customer).

When unsure, choose `weak`.

=== Q: delegate-weak | Memory | intermediate
Why are delegates usually declared `weak`, and what's required to do that?
---
A view controller typically owns a view (strong reference), and the view points back to its delegate (the controller). If the delegate reference were strong, that would be a retain cycle.

`weak` requires a **class-bound** protocol, because only reference types can be weak:

```swift
protocol PickerDelegate: AnyObject { func didPick(_ value: Int) }
final class Picker { weak var delegate: (any PickerDelegate)? }
```

=== Q: capture-self | Memory | intermediate
Do you always need `[weak self]` in closures?
---
No. You need it when the closure is **stored** (directly or indirectly) by `self`, or outlives `self` in a way that keeps `self` alive longer than wanted.

You usually **don't** need it for:
- non-escaping closures (`map`, `filter`, SwiftUI `body`)
- short-lived work where keeping `self` alive briefly is fine
- structs (value types aren't reference-counted)

In `Task { }` inside a class, `self` is retained until the task finishes. Use `[weak self]` for long-running or repeating tasks, and cancel tasks when appropriate.

=== Q: error-handling | Swift Basics | beginner
How does error handling work in Swift?
---
Functions that can fail are marked `throws` and signal failure with `throw SomeError`. Callers must use `try` inside `do { } catch { }`, or propagate the error by being `throws` themselves.

```swift
do {
    let user = try decoder.decode(User.self, from: data)
} catch let DecodingError.keyNotFound(key, _) {
    print("Missing \(key)")
} catch {
    print(error)
}
```

- `try?` turns errors into `nil`; `try!` crashes on error.
- `Result<Success, Failure>` stores an outcome as a value.
- `defer` runs cleanup however the scope exits.
- Swift 6 adds **typed throws**: `throws(ParseError)`.

=== Q: typed-throws | Swift Basics | advanced
What are typed throws and when should you use them?
---
Swift 6 lets a function declare the **exact error type** it throws: `func parse() throws(ParseError) -> Int`. In a `catch` block, `error` is then `ParseError` rather than `any Error`, so you can switch over it exhaustively. It also works in generic code and in environments where existential boxing is costly (embedded).

Use typed throws for **closed, internal** error domains, such as a parser or validator. For public APIs that may evolve or wrap other errors, untyped `throws` is usually more flexible.

=== Q: access-levels | Swift Basics | beginner
List Swift's access levels.
---
From most to least restrictive:

- `private`: the enclosing declaration (plus its extensions in the same file)
- `fileprivate`: the current file
- `internal` (**default**): the whole module
- `package`: modules in the same Swift package
- `public`: visible to other modules, but **not** subclassable or overridable outside
- `open`: public **and** subclassable or overridable outside the module

`private(set)` makes a setter more restrictive than its getter.

=== Q: async-await | Concurrency | intermediate
How does async/await improve on completion handlers?
---
- **Linear code**: no nested callbacks ("pyramid of doom").
- **Errors** use normal `try`/`catch` instead of a `Result` parameter.
- The compiler guarantees each path **returns exactly once**, so you can't forget to call a completion handler or call it twice.
- **Structured concurrency**: child tasks, automatic cancellation propagation.
- Works with actors for **compile-time data-race safety**.

`await` marks suspension points where the function may pause **without blocking a thread**.

=== Q: task-vs-detached | Concurrency | intermediate
What's the difference between `Task { }` and `Task.detached { }`?
---
`Task { }` creates **unstructured** top-level work that **inherits** the current actor (for example the main actor), the priority and task-local values.

`Task.detached { }` inherits **nothing**: no actor isolation and no task-locals. It's rarely needed; use it for genuinely independent background work.

Neither is a *child* task. For structured children use `async let` or task groups, which are cancelled with their parent automatically.

=== Q: structured-concurrency | Concurrency | advanced
What is structured concurrency?
---
Concurrent work forms a **tree**: child tasks (from `async let` or `withTaskGroup`) belong to a parent scope and **cannot outlive it**. The scope doesn't return until all children finish.

Benefits:
- **Cancellation propagates** from parent to children automatically.
- **Errors propagate**: if one child throws in a throwing group, the siblings are cancelled.
- No leaked or forgotten background work, and priorities are inherited.

Unstructured `Task {}` is the escape hatch when you need work to outlive the scope.

=== Q: actors | Concurrency | intermediate
What is an actor and what problem does it solve?
---
An actor is a reference type that **protects its mutable state** by allowing only one task at a time to run its isolated code. This prevents **data races**.

Accessing an actor's isolated properties or methods from outside requires `await`, because you may have to wait your turn.

```swift
actor Counter { var value = 0; func increment() { value += 1 } }
let c = Counter(); await c.increment()
```

Caveat: actors are **reentrant**. At each `await` inside an actor method, other calls can run, so re-check state after suspension points.

=== Q: sendable | Concurrency | advanced
What is `Sendable`?
---
`Sendable` marks types that are safe to share across concurrency domains (tasks and actors) without data races.

- Value types whose stored properties are all Sendable conform **implicitly**.
- Actors are Sendable.
- `final` classes with only immutable `let` Sendable properties can conform.
- `@Sendable` closures can't capture mutable state.
- `@unchecked Sendable` opts out of checking (use only with your own locking).

In the Swift 6 language mode, passing non-Sendable values across isolation boundaries is a **compile error**.

=== Q: main-actor | Concurrency | intermediate
What is `@MainActor` and when do you use it?
---
`@MainActor` is a **global actor** representing the main thread. Code isolated to it runs on the main thread, which is required for UI updates in UIKit and SwiftUI.

Apply it to view models, UI-touching functions or whole types. From other contexts, call such code with `await`, or use `await MainActor.run { }`.

SwiftUI `View`s are main-actor isolated, so your view code is already on the main actor. Newer projects can even make main-actor isolation the **default** for a module.

=== Q: data-race | Concurrency | intermediate
What is a data race and how does Swift 6 prevent it?
---
A data race is when two threads access the same memory **at the same time**, at least one of them writes, and there's no synchronisation. The result is unpredictable values and crashes.

Swift 6's language mode turns concurrency checking into **errors**. Using **actor isolation**, **Sendable** checking and region-based isolation analysis, the compiler proves that mutable state is never shared unsafely. Most races are now caught **at compile time** instead of in production.

=== Q: gcd-vs-async | Concurrency | advanced
How does Swift concurrency differ from GCD (DispatchQueue)?
---
- **GCD** schedules closures on queues. Blocking a thread (with semaphores, for example) can cause **thread explosion**, and the compiler can't check data races.
- **Swift concurrency** uses a cooperative thread pool sized to the CPU cores. Tasks **suspend** instead of blocking, actors and Sendable give **compile-time safety**, and you get structured cancellation and priorities.

Rule: don't block (`semaphore.wait()`, `sleep`) inside async code. Use `await` instead.

=== Q: swiftui-state | SwiftUI | beginner
What do `@State`, `@Binding` and `@Environment` do?
---
- `@State`: private storage **owned by a view**. Changing it re-renders the view. Use it for local UI state (and to own `@Observable` models).
- `@Binding`: a two-way reference to state owned by **someone else**, created with `$value`. It lets child views edit parent state.
- `@Environment`: reads values passed down the view tree, both system values (`\.colorScheme`, `\.dismiss`, `\.modelContext`) and your own observable objects (`@Environment(Cart.self)`).

=== Q: observable-vs-observableobject | SwiftUI | intermediate
`@Observable` vs `ObservableObject`: what changed?
---
`ObservableObject` (Combine) required `@Published` on each property, and **any** published change invalidated **every** observing view.

The `@Observable` macro (iOS 17+) tracks **which properties each view actually reads** and refreshes only those views. That gives better performance and simpler code (plain `var`s). With it you use `@State` instead of `@StateObject`, plain properties or `@Bindable` instead of `@ObservedObject`, and `@Environment(Type.self)` instead of `@EnvironmentObject`.

=== Q: swiftui-view-identity | SwiftUI | advanced
How does SwiftUI decide when to update or recreate a view?
---
Views are lightweight **value descriptions**. SwiftUI diffs them by **identity**:

- **Structural identity**: the view's position in the hierarchy (including `if`/`else` branches, which are different views).
- **Explicit identity**: `id`s in `ForEach` / `List`, or the `.id(_:)` modifier.

When a view's identity changes, its **state is reset** and its `onAppear`/`task` modifiers rerun. When only data changes, `body` is re-evaluated and the minimal changes are applied. Using unstable ids (like `UUID()` created in `body`) causes state loss and poor performance.

=== Q: some-view | SwiftUI | beginner
Why does `body` return `some View`?
---
`body` combines many generic view types, so its real type is something huge like `VStack<TupleView<(Text, Button<Text>)>>`. `some View` is an **opaque return type**: the compiler knows the exact concrete type (for fast, static diffing), but you don't have to write it.

It must be **one** concrete type, so branching uses `@ViewBuilder` (which wraps `if`/`else` in `_ConditionalContent`), or `AnyView` (type-erased, which costs performance).

=== Q: swiftui-lifecycle | SwiftUI | intermediate
What's the difference between `onAppear` and `.task`?
---
`onAppear` runs a synchronous closure when the view appears. `.task { }` starts an **async task** when the view appears and **cancels it automatically** when the view disappears. `.task(id:)` also restarts when the id changes.

Prefer `.task` for loading data: you get cancellation for free, so there are no updates to views that are gone.

=== Q: list-performance | SwiftUI | intermediate
How do you keep long SwiftUI lists fast?
---
- Use `List` or `LazyVStack` inside a `ScrollView` (both lazy) for long content.
- Give rows **stable, unique ids** (`Identifiable`).
- Keep `body` and row views cheap: precompute formatted strings and avoid heavy work or sorting inside `body`.
- Split large views into smaller subviews, so changes re-evaluate less.
- Load images asynchronously (`AsyncImage` or a caching loader).
- Profile with **Instruments → SwiftUI** to find excessive body evaluations.

=== Q: mvvm | iOS & Architecture | intermediate
Describe MVVM in a SwiftUI app.
---
- **Model**: data and domain types (`Post`, `User`) and services or repositories (networking, persistence).
- **ViewModel**: an `@Observable` (usually `@MainActor`) class holding screen state (`loading`, `loaded`, `failed`) and actions (`load()`, `delete()`). It's testable without UI.
- **View**: declarative layout that reads the view model and forwards user actions.

Dependencies (an API client, for example) are injected as protocols, so previews and tests can use mocks. For simple screens, plain `@State` in the view is fine. Don't add a view model "just because".

=== Q: dependency-injection | iOS & Architecture | intermediate
How would you do dependency injection in Swift?
---
Pass dependencies in, instead of creating them internally:

- **Initializer injection** (preferred): `init(api: any PostsAPI)`.
- **Property injection** for optional collaborators.
- **SwiftUI Environment**: `.environment(service)` for app-wide services.

Depend on **protocols**, so tests and previews can pass fakes:

```swift
protocol PostsAPI { func posts() async throws -> [Post] }
struct MockPostsAPI: PostsAPI { func posts() async throws -> [Post] { [.sample] } }
```

Avoid singletons for anything you want to test.

=== Q: codable | iOS & Architecture | beginner
How does Codable work, and how do you handle mismatched JSON keys?
---
`Codable` = `Encodable & Decodable`. The compiler synthesizes the implementation when all properties are Codable. Use `JSONDecoder().decode(T.self, from: data)`.

For mismatched keys:
- `decoder.keyDecodingStrategy = .convertFromSnakeCase` for `snake_case` → `camelCase`
- a custom `enum CodingKeys: String, CodingKey { case imageURL = "image_url" }`
- a custom `init(from:)` for complex transforms, defaults or nested containers

Also set `dateDecodingStrategy` (`.iso8601`, for example) for dates.

=== Q: persistence-options | iOS & Architecture | beginner
What options do you have to store data on iOS?
---
- `UserDefaults` / `@AppStorage`: small settings (never secrets)
- **Keychain**: passwords, tokens, keys (encrypted)
- **SwiftData** (iOS 17+) or **Core Data**: structured object graphs and queries
- **Files** (`FileManager`, the Documents or Caches directories): images, documents, JSON
- **SQLite** directly, or libraries like GRDB
- **CloudKit / iCloud** for sync across a user's devices

=== Q: app-lifecycle | iOS & Architecture | beginner
What are the main app lifecycle states on iOS?
---
Not running → **inactive** (in the foreground but not receiving events, for example during a call or the app switcher) → **active** → **background** (briefly running code) → **suspended** (in memory, not running) → possibly terminated by the system.

In SwiftUI, observe `@Environment(\.scenePhase)` (`.active`, `.inactive`, `.background`) to save data or pause work. UIKit uses the `UIApplicationDelegate` and `UISceneDelegate` callbacks.

=== Q: uikit-vs-swiftui | iOS & Architecture | intermediate
SwiftUI or UIKit? Can you mix them?
---
**SwiftUI** is declarative, has far less code, live previews and multi-platform support, and is Apple's direction for new UI. **UIKit** is imperative, mature, and offers the finest control over complex custom UI and older-iOS support.

Most modern apps are SwiftUI-first, and you can **mix** them:
- UIKit inside SwiftUI: `UIViewRepresentable` / `UIViewControllerRepresentable`
- SwiftUI inside UIKit: `UIHostingController`

=== Q: testing | iOS & Architecture | intermediate
How do you test iOS code?
---
- **Unit tests** with **Swift Testing** (`@Test`, `#expect`, parameterized tests) or XCTest. Test view models, parsers and business logic.
- **Mock dependencies** through protocols so tests are fast and don't touch the network.
- **Async tests**: `@Test func load() async throws`.
- **UI tests** with XCUITest for critical flows.
- **Snapshot tests** (community libraries) for UI regressions.

Run tests with ⌘U and in CI (Xcode Cloud or GitHub Actions).

=== Q: performance-tools | iOS & Architecture | advanced
An app's scrolling stutters. How do you investigate?
---
1. Reproduce on a **real device** in a **Release** build.
2. Use **Instruments**: Time Profiler (main-thread work), the SwiftUI instrument (excessive `body` evaluations), Hitches, Allocations and Leaks.
3. Common culprits: heavy work in `body` or `cellForRow`, synchronous image decoding, formatting allocations per frame, non-lazy stacks, unstable identities, large images.
4. Fix by moving work off the main actor, caching, downsampling images, and using lazy containers.
5. Measure again to confirm.

=== Q: property-wrapper | Types & Protocols | advanced
What is a property wrapper? Give an example.
---
A property wrapper encapsulates reusable get/set logic for properties. You define a type with `@propertyWrapper` and a `wrappedValue`, and optionally a `projectedValue`, which you access with `$`.

```swift
@propertyWrapper struct Trimmed {
    private var value = ""
    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespaces) }
    }
    init(wrappedValue: String) { self.wrappedValue = wrappedValue }
}
struct Form { @Trimmed var name = "" }
```

SwiftUI's `@State`, `@Binding`, `@Environment` and `@AppStorage` are property wrappers.

=== Q: macros | Types & Protocols | advanced
What are Swift macros?
---
Macros generate code at **compile time** from your source, checked by the compiler.

- **Freestanding** macros (`#Preview`, `#Predicate`, `#expect`) produce expressions or declarations.
- **Attached** macros (`@Observable`, `@Model`, `@Test`) add members, conformances or accessors to a declaration.

They remove boilerplate safely and can only add code, never silently remove yours. In Xcode, right-click → **Expand Macro** shows the generated code. Custom macros are built in a package using **SwiftSyntax**.

=== Q: noncopyable | Types & Protocols | advanced
What are noncopyable (`~Copyable`) types used for?
---
A `~Copyable` type has **unique ownership**: it can't be implicitly copied, and passing it around **moves** it. The compiler enforces "use exactly once" rules with `consuming` and `borrowing` parameters, and noncopyable structs can have a `deinit`.

Use cases: unique resources (file descriptors, locks), one-time tokens, and high-performance code that avoids reference counting and copies. Most app code doesn't need them.

=== Q: dispatch-static-dynamic | Types & Protocols | advanced
What's the difference between static and dynamic dispatch in Swift?
---
- **Static dispatch**: the compiler knows exactly which function to call. It's fastest and inlinable. Used for structs and enums, `final` classes and members, `private` members, and protocol-extension-only methods.
- **Dynamic dispatch**: the call is resolved at runtime through a **vtable** (overridable class methods), a **witness table** (protocol requirements via generics or existentials), or the **Objective-C runtime** (`@objc dynamic`).

Marking classes `final` and preferring value types and generics helps the compiler use static dispatch.

=== Q: code-reverse | Coding Challenges | beginner
Write a function that checks whether a string is a palindrome (ignoring case, spaces and punctuation).
---
```swift
func isPalindrome(_ text: String) -> Bool {
    let chars = text.lowercased().filter { $0.isLetter || $0.isNumber }
    return chars == String(chars.reversed())
}

isPalindrome("A man, a plan, a canal: Panama")   // true
isPalindrome("Swift")                            // false
```

Talking points: `Character` properties handle Unicode; it's O(n) time and O(n) extra space. A two-pointer version over an array of characters avoids building the reversed string.

=== Q: code-fizzbuzz | Coding Challenges | beginner
Implement FizzBuzz for 1...100 in idiomatic Swift.
---
```swift
for n in 1...100 {
    switch (n.isMultiple(of: 3), n.isMultiple(of: 5)) {
    case (true, true): print("FizzBuzz")
    case (true, false): print("Fizz")
    case (false, true): print("Buzz")
    case (false, false): print(n)
    }
}
```

Using a `switch` on a tuple shows off pattern matching and is exhaustive by construction.

=== Q: code-two-sum | Coding Challenges | intermediate
Given an array of Ints and a target, return the indices of two numbers that add up to the target.
---
```swift
func twoSum(_ nums: [Int], _ target: Int) -> (Int, Int)? {
    var seen: [Int: Int] = [:]                // value -> index
    for (i, n) in nums.enumerated() {
        if let j = seen[target - n] { return (j, i) }
        seen[n] = i
    }
    return nil
}

twoSum([2, 7, 11, 15], 9)   // (0, 1)
```

O(n) time and O(n) space, using a dictionary. Mention the brute-force O(n²) alternative and why the hash map is better.

=== Q: code-anagrams | Coding Challenges | intermediate
Group a list of words into anagrams.
---
```swift
func groupAnagrams(_ words: [String]) -> [[String]] {
    Dictionary(grouping: words) { String($0.lowercased().sorted()) }
        .values
        .map { $0.sorted() }
}

groupAnagrams(["eat", "tea", "tan", "ate", "nat", "bat"])
// [["ate","eat","tea"], ["nat","tan"], ["bat"]]
```

The key is the sorted letters. That costs O(n · k log k) for n words of length k; a 26-letter count array as the key gives O(n · k).

=== Q: code-debounce | Coding Challenges | advanced
Implement a debounced search: only call the API 300 ms after the user stops typing.
---
```swift
@Observable @MainActor
final class SearchModel {
    var query = "" { didSet { scheduleSearch() } }
    private(set) var results: [String] = []
    private var task: Task<Void, Never>?

    private func scheduleSearch() {
        task?.cancel()                                   // cancel the previous attempt
        let q = query
        task = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, !q.isEmpty else { return }
            results = (try? await api.search(q)) ?? []
        }
    }
}
```

Each keystroke cancels the pending task, so only the last one survives the delay. In SwiftUI you can also use `.task(id: query) { try? await Task.sleep(...) ... }`, which cancels automatically.

=== Q: code-lru | Coding Challenges | advanced
Design a simple thread-safe in-memory cache with a maximum size.
---
```swift
actor LRUCache<Key: Hashable & Sendable, Value: Sendable> {
    private var storage: [Key: Value] = [:]
    private var order: [Key] = []          // most recent at the end
    private let capacity: Int

    init(capacity: Int) { self.capacity = capacity }

    func value(for key: Key) -> Value? {
        guard let v = storage[key] else { return nil }
        touch(key)
        return v
    }

    func set(_ value: Value, for key: Key) {
        storage[key] = value
        touch(key)
        if order.count > capacity {
            storage[order.removeFirst()] = nil   // evict least recently used
        }
    }

    private func touch(_ key: Key) {
        order.removeAll { $0 == key }
        order.append(key)
    }
}
```

An **actor** gives thread safety with no locks. For O(1) operations, mention a dictionary plus a doubly-linked list, or `NSCache` for automatic memory-pressure eviction.
