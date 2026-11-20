=== FILE: async-await.md ===
---
title: async / await
summary: Write asynchronous code that reads like normal code.
minutes: 9
---
Slow work (network, disk, heavy computation) must not freeze the UI. With **async/await**, you mark functions that can suspend and `await` their results.

```swift
func fetchQuote() async throws -> String {
    let url = URL(string: "https://example.com/quote")!
    let (data, response) = try await URLSession.shared.data(from: url)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    return String(decoding: data, as: UTF8.self)
}
```

- `async`: this function can **suspend** (pause without blocking a thread).
- `await`: a possible suspension point; other work runs meanwhile.
- `async throws` + `try await`: async work that can fail.

## Calling async code

```swift
// From synchronous code (e.g. a button tap) start a Task:
Button("Load") {
    Task {
        do {
            quote = try await fetchQuote()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// In SwiftUI, .task runs when the view appears and cancels when it disappears:
Text(quote).task { quote = (try? await fetchQuote()) ?? "Offline" }
```

## Doing things in parallel: async let

```swift
async let profile = api.profile(id: 1)
async let posts = api.posts(userID: 1)
let (p, list) = try await (profile, posts)   // both requests run at the same time
```

:::analogy
`await` is like putting the kettle on and checking your messages while it boils, instead of staring at the kettle.
:::

```quiz
[
 {"q": "What does `await` mean?", "options": ["Block the thread", "A point where the function may suspend while waiting", "Run on a new thread", "Retry"], "answer": 1, "why": "Awaiting suspends without blocking the thread."},
 {"q": "How do you call an async function from a button action?", "options": ["Directly", "Wrap it in Task { }", "Use DispatchQueue.async", "You can't"], "answer": 1, "why": "Task creates an async context from synchronous code."},
 {"q": "What does `async let` enable?", "options": ["Lazy values", "Running child tasks concurrently", "Global variables", "Caching"], "answer": 1, "why": "Multiple async lets run in parallel until awaited."}
]
```

=== FILE: tasks-and-groups.md ===
---
title: Tasks, Task Groups & Cancellation
summary: Structured concurrency for many jobs at once.
minutes: 9
---
## Task groups: a dynamic number of child tasks

```swift
func downloadAll(_ urls: [URL]) async throws -> [Data] {
    try await withThrowingTaskGroup(of: Data.self) { group in
        for url in urls {
            group.addTask {
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            }
        }
        var results: [Data] = []
        for try await data in group {      // collect as each finishes
            results.append(data)
        }
        return results
    }
}
```

**Structured concurrency**: child tasks can't outlive their parent scope. If one throws, the others are cancelled automatically.

## Cancellation is cooperative

```swift
let task = Task {
    for page in 1...100 {
        try Task.checkCancellation()          // throws CancellationError if cancelled
        await process(page)
    }
}
task.cancel()
```

## Task priority and detached tasks

```swift
Task(priority: .background) { await cleanUpCache() }
Task.detached { /* doesn't inherit actor or priority: use rarely */ }
```

## AsyncSequence

```swift
for try await line in url.lines {    // stream lines as they download
    print(line)
}

let stream = AsyncStream<Int> { continuation in
    for i in 1...3 { continuation.yield(i) }
    continuation.finish()
}
for await value in stream { print(value) }
```

```quiz
[
 {"q": "What happens to child tasks in a throwing task group when one throws?", "options": ["They keep running", "The others are cancelled", "The app crashes", "They restart"], "answer": 1, "why": "Structured concurrency cancels siblings on error."},
 {"q": "Is cancellation automatic in Swift?", "options": ["Yes, tasks stop instantly", "No, it's cooperative: code must check for it", "Only on the main actor", "Only for detached tasks"], "answer": 1, "why": "Tasks must check Task.isCancelled or call checkCancellation()."}
]
```

=== FILE: actors-sendable.md ===
---
title: Actors & Sendable
summary: Protect shared mutable state from data races.
minutes: 10
---
A **data race** happens when two threads access the same memory at the same time and at least one writes. The result is random bugs and crashes. Swift 6 catches data races at **compile time**.

## Actors

An **actor** is like a class, but only one task at a time can touch its mutable state.

```swift
actor BankAccount {
    private(set) var balance = 0.0

    func deposit(_ amount: Double) {
        balance += amount
    }

    func withdraw(_ amount: Double) throws {
        guard amount <= balance else { throw BankError.insufficientFunds }
        balance -= amount
    }
}

let account = BankAccount()
await account.deposit(100)          // calls from outside need await
print(await account.balance)
```

## Sendable

A type is **Sendable** if it's safe to pass between concurrent tasks:

- Value types whose properties are all Sendable (most structs and enums) are Sendable automatically.
- Actors are Sendable.
- Classes are Sendable only if they're `final` and have immutable (`let`) Sendable properties, or they use `@unchecked Sendable` with your own locking.

```swift
struct Order: Sendable { let id: Int; let total: Double }

final class Config: Sendable {
    let apiURL: URL
    init(apiURL: URL) { self.apiURL = apiURL }
}
```

## Reentrancy

Inside an actor, every `await` is a point where other calls can run. Re-check assumptions after awaiting:

```swift
actor ImageCache {
    private var cache: [URL: Data] = [:]

    func image(for url: URL) async throws -> Data {
        if let cached = cache[url] { return cached }
        let (data, _) = try await URLSession.shared.data(from: url)
        cache[url] = data          // another call may have filled it meanwhile, and that's fine
        return data
    }
}
```

```quiz
[
 {"q": "What does an actor guarantee?", "options": ["Faster code", "Only one task at a time accesses its mutable state", "Runs on the main thread", "No await needed"], "answer": 1, "why": "Actor isolation serialises access to its state."},
 {"q": "Which is automatically Sendable?", "options": ["A non-final class with var properties", "A struct with only Sendable stored properties", "Any closure", "UIView"], "answer": 1, "why": "Value types with Sendable members conform implicitly."}
]
```

=== FILE: main-actor.md ===
---
title: The Main Actor & Swift 6 Concurrency
summary: UI work on the main thread, isolation and strict checking.
minutes: 8
---
All UI updates must happen on the **main thread**. In Swift that's the **main actor**.

```swift
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var name = ""

    func load() async {
        let profile = await api.fetchProfile()   // may run elsewhere
        name = profile.name                       // back on the main actor: safe UI update
    }
}

// Hop to the main actor from anywhere:
await MainActor.run { label.text = "Done" }
```

SwiftUI views are already main-actor isolated, so their `body` and actions run on the main actor.

## Swift 6 language mode

Swift 6 turns concurrency warnings into **errors**: the compiler proves your code has no data races. Typical messages and fixes:

| Error says... | Usual fix |
|---|---|
| "Sending X risks causing data races" | Make the type `Sendable` (or a struct) |
| "Main actor-isolated property can't be referenced from a nonisolated context" | Mark the caller `@MainActor` or `await` it |
| "Static property is not concurrency-safe" | Make it `let`, or isolate it to an actor |

```swift
// Mark work that doesn't touch actor state as nonisolated
actor Store {
    nonisolated let id = UUID()
    nonisolated func describe() -> String { "Store \(id)" }
}
```

:::tip
Newer Xcode templates can make the **main actor the default** for app code ("approachable concurrency"), so you only opt *out* for background work. Check your target's build settings for **Default Actor Isolation**.
:::

```quiz
[
 {"q": "Where must UI updates happen?", "options": ["Any thread", "The main actor (main thread)", "A background actor", "A detached task"], "answer": 1, "why": "UIKit and SwiftUI must be updated on the main thread."},
 {"q": "What does Swift 6 language mode change?", "options": ["Removes optionals", "Turns data-race warnings into compile errors", "Removes classes", "Makes everything async"], "answer": 1, "why": "Strict concurrency checking becomes an error."}
]
```

=== FILE: swiftui-basics.md ===
---
title: SwiftUI Basics
summary: Views, modifiers and layout stacks.
minutes: 9
---
In SwiftUI you **describe** what the UI should look like for the current state, and SwiftUI updates the screen when the state changes.

```swift
struct ProfileCard: View {
    let name: String
    let role: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.headline)
                Text(role).font(.subheadline).foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }
}
```

## Building blocks

| View | Purpose |
|---|---|
| `Text`, `Image`, `Label` | Content |
| `VStack`, `HStack`, `ZStack` | Vertical, horizontal and layered layout |
| `Spacer`, `Divider` | Spacing |
| `Button`, `Toggle`, `TextField`, `Slider`, `Picker` | Controls |
| `List`, `ScrollView`, `LazyVGrid` | Scrolling content |
| `NavigationStack`, `TabView`, `.sheet` | Navigation |

## Modifiers: order matters

```swift
Text("Hi")
    .padding()
    .background(.yellow)   // yellow includes the padding

Text("Hi")
    .background(.yellow)
    .padding()             // yellow only behind the text
```

:::tip
**SF Symbols**: `Image(systemName:)` gives you thousands of free icons. Browse them in Apple's SF Symbols app.
:::

```quiz
[
 {"q": "What does `some View` mean as a return type?", "options": ["Any view at runtime", "One specific view type the compiler knows (opaque type)", "An optional view", "A class"], "answer": 1, "why": "body returns an opaque type: concrete but hidden."},
 {"q": "Does modifier order matter?", "options": ["No", "Yes, each modifier wraps the previous result", "Only for Text", "Only for colors"], "answer": 1, "why": "padding then background differs from background then padding."}
]
```

=== FILE: state-and-binding.md ===
---
title: State & Bindings
summary: @State, @Binding and the single source of truth.
minutes: 9
---
## @State: local view state

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Count: \(count)").font(.largeTitle)
            Button("Add one") { count += 1 }   // changing state re-renders the view
                .buttonStyle(.borderedProminent)
        }
    }
}
```

## @Binding: let a child edit the parent's state

```swift
struct SettingsView: View {
    @State private var notifications = true

    var body: some View {
        NotificationToggle(isOn: $notifications)   // $ creates a binding
    }
}

struct NotificationToggle: View {
    @Binding var isOn: Bool
    var body: some View {
        Toggle("Notifications", isOn: $isOn)
    }
}
```

## Forms

```swift
struct SignUpView: View {
    @State private var email = ""
    @State private var agree = false

    var isValid: Bool { email.contains("@") && agree }

    var body: some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            Toggle("I agree to the terms", isOn: $agree)
            Button("Create account") { }
                .disabled(!isValid)
        }
    }
}
```

:::note
**Single source of truth**: each piece of data should live in exactly one place. Other views receive it read-only or through a `Binding`.
:::

```quiz
[
 {"q": "What does $count create from @State var count?", "options": ["A copy", "A Binding to it", "A publisher", "A string"], "answer": 1, "why": "The $ prefix projects a Binding."},
 {"q": "Who should own @State?", "options": ["Any view", "The view where the state lives (keep it private)", "The App struct only", "A child view"], "answer": 1, "why": "@State is private, view-owned storage."}
]
```

=== FILE: observable.md ===
---
title: Observation: @Observable Models
summary: Share app state across views with the Observation framework.
minutes: 9
---
For data shared by several views, use a model class marked with the **`@Observable`** macro. SwiftUI tracks exactly which properties each view reads and refreshes only those views.

```swift
import Observation

@Observable
final class CartModel {
    var items: [Product] = []
    var total: Double { items.reduce(0) { $0 + $1.price } }

    func add(_ product: Product) { items.append(product) }
}

@main
struct ShopApp: App {
    @State private var cart = CartModel()      // the owner keeps it alive

    var body: some Scene {
        WindowGroup {
            ContentView().environment(cart)   // share it down the tree
        }
    }
}

struct CartBadge: View {
    @Environment(CartModel.self) private var cart
    var body: some View {
        Label("\(cart.items.count)", systemImage: "cart")
    }
}
```

## Editing an observable with bindings

```swift
struct ProfileEditor: View {
    @Bindable var profile: Profile         // Profile is @Observable
    var body: some View {
        TextField("Name", text: $profile.name)
    }
}
```

## Old vs new

| iOS 13–16 (Combine) | iOS 17+ (Observation) |
|---|---|
| `class X: ObservableObject` | `@Observable class X` |
| `@Published var` | plain `var` |
| `@StateObject` / `@ObservedObject` | `@State` / a plain property |
| `@EnvironmentObject` | `@Environment(X.self)` |

```quiz
[
 {"q": "Which macro makes a class observable by SwiftUI on iOS 17+?", "options": ["@Published", "@Observable", "@State", "@Model"], "answer": 1, "why": "@Observable generates the observation tracking code."},
 {"q": "How do you get bindings to an observable model's properties?", "options": ["@Binding", "@Bindable", "@State only", "$ on the class"], "answer": 1, "why": "@Bindable lets you write $model.property."}
]
```

=== FILE: lists-navigation.md ===
---
title: Lists & Navigation
summary: List, ForEach, NavigationStack, sheets and tabs.
minutes: 9
---
```swift
struct Book: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var author: String
}

struct LibraryView: View {
    @State private var books = [
        Book(title: "Things Fall Apart", author: "Chinua Achebe"),
        Book(title: "Americanah", author: "Chimamanda Ngozi Adichie"),
    ]
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    NavigationLink(value: book) {
                        VStack(alignment: .leading) {
                            Text(book.title).font(.headline)
                            Text(book.author).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { books.remove(atOffsets: $0) }   // swipe to delete
            }
            .navigationTitle("Library")
            .navigationDestination(for: Book.self) { book in
                BookDetail(book: book)
            }
            .toolbar {
                Button("Add", systemImage: "plus") { showingAdd = true }
            }
            .sheet(isPresented: $showingAdd) {
                AddBookView { books.append($0) }
            }
            .searchable(text: .constant(""))
        }
    }
}
```

## Tabs

```swift
TabView {
    Tab("Home", systemImage: "house") { HomeView() }
    Tab("Settings", systemImage: "gear") { SettingsView() }
}
```

## Programmatic navigation

```swift
@State private var path = NavigationPath()

NavigationStack(path: $path) { ... }
path.append(book)        // push
path.removeLast()        // pop
path = NavigationPath()  // pop to root
```

```quiz
[
 {"q": "What does ForEach need to tell items apart?", "options": ["An index", "Identifiable items or an id: key path", "Equatable", "Nothing"], "answer": 1, "why": "SwiftUI tracks rows by identity."},
 {"q": "Which container provides push navigation in modern SwiftUI?", "options": ["NavigationView", "NavigationStack", "UINavigationController", "TabView"], "answer": 1, "why": "NavigationStack replaced NavigationView."}
]
```

=== FILE: networking-codable.md ===
---
title: Networking & Codable
summary: Call REST APIs and decode JSON into Swift types.
minutes: 10
---
## Codable

```swift
struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

let json = #"{"id": 1, "userId": 7, "title": "Hello", "body": "First post"}"#.data(using: .utf8)!
let post = try JSONDecoder().decode(Post.self, from: json)
let back = try JSONEncoder().encode(post)
```

## snake_case and custom keys

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase   // published_year -> publishedYear
decoder.dateDecodingStrategy = .iso8601

struct Book: Codable {
    let title: String
    let publishedYear: Int?
    let coverURL: URL?

    enum CodingKeys: String, CodingKey {
        case title, publishedYear
        case coverURL = "cover"              // JSON key "cover"
    }
}
```

## A small API client

```swift
enum APIError: Error { case badStatus(Int) }

struct APIClient {
    var baseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    func get<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: baseURL.appending(path: path))
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else { throw APIError.badStatus(status) }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body) async throws -> T {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

let posts: [Post] = try await APIClient().get("posts")
```

## In a view: loading, loaded, failed

```swift
struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var error: String?

    var body: some View {
        List(posts) { Text($0.title) }
            .overlay { if let error { ContentUnavailableView("Offline", systemImage: "wifi.slash", description: Text(error)) } }
            .task {
                do { posts = try await APIClient().get("posts") }
                catch { self.error = error.localizedDescription }
            }
    }
}
```

:::tip
To send a Laravel Sanctum token, add `request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")`, and store tokens in the **Keychain**, not UserDefaults.
:::

```quiz
[
 {"q": "Which protocol pair does Codable combine?", "options": ["Equatable & Hashable", "Encodable & Decodable", "Sendable & Hashable", "Identifiable & Codable"], "answer": 1, "why": "Codable = Encodable & Decodable."},
 {"q": "How do you map published_year to publishedYear automatically?", "options": ["CodingKeys only", "keyDecodingStrategy = .convertFromSnakeCase", "Rename the JSON", "Use a dictionary"], "answer": 1, "why": "The decoder converts snake_case keys for you."},
 {"q": "Where should auth tokens be stored on iOS?", "options": ["UserDefaults", "The Keychain", "A text file", "The app bundle"], "answer": 1, "why": "The Keychain stores secrets encrypted."}
]
```

=== FILE: swiftdata.md ===
---
title: Saving Data with SwiftData
summary: Persist models on the device with @Model and @Query.
minutes: 9
---
**SwiftData** (iOS 17+) saves Swift objects on the device with almost no code.

```swift
import SwiftData

@Model
final class Habit {
    var name: String
    var createdAt: Date
    var completions: [Date] = []

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }

    var doneToday: Bool { completions.contains { Calendar.current.isDateInToday($0) } }
}

@main
struct HabitsApp: App {
    var body: some Scene {
        WindowGroup { HabitList() }
            .modelContainer(for: Habit.self)          // sets up the database
    }
}

struct HabitList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]

    var body: some View {
        List {
            ForEach(habits) { habit in
                Button {
                    habit.completions.append(.now)     // changes save automatically
                } label: {
                    Label(habit.name, systemImage: habit.doneToday ? "checkmark.circle.fill" : "circle")
                }
            }
            .onDelete { offsets in
                for i in offsets { context.delete(habits[i]) }
            }
        }
        .toolbar {
            Button("Add") { context.insert(Habit(name: "Drink water")) }
        }
    }
}
```

## Filtering with #Predicate

```swift
@Query(filter: #Predicate<Habit> { $0.name.contains("Read") }) var reading: [Habit]
```

## Other options

- **UserDefaults** (or `@AppStorage`): small settings like a theme
- **Keychain**: secrets and tokens
- **Files** (`FileManager`): documents and images
- **Core Data**: the older, very powerful framework SwiftData is built on

```quiz
[
 {"q": "Which macro turns a class into a SwiftData model?", "options": ["@Observable", "@Model", "@Entity", "@Query"], "answer": 1, "why": "@Model makes the class persistable and observable."},
 {"q": "What does @Query do?", "options": ["Sends HTTP requests", "Fetches models and keeps the view updated", "Deletes data", "Creates the container"], "answer": 1, "why": "@Query is a live, auto-updating fetch."},
 {"q": "Where should a small setting like a theme go?", "options": ["SwiftData", "@AppStorage / UserDefaults", "Keychain", "A server"], "answer": 1, "why": "UserDefaults is ideal for small preferences."}
]
```

=== FILE: protocols-advanced.md ===
---
title: Associated Types & Protocol-Oriented Design
summary: Generic protocols, primary associated types and composition.
minutes: 9
---
## Associated types

A protocol can have a placeholder type that each conforming type fills in:

```swift
protocol Repository {
    associatedtype Item: Identifiable
    func all() async throws -> [Item]
    func save(_ item: Item) async throws
}

struct InMemoryNotes: Repository {
    private(set) var notes: [Note] = []
    func all() async throws -> [Note] { notes }
    func save(_ item: Note) async throws { /* ... */ }
}
```

## Primary associated types

```swift
protocol Store<Item> {            // Item is "primary"
    associatedtype Item
    func load() -> [Item]
}

func show(_ store: some Store<String>) { print(store.load()) }
let stores: [any Store<Int>] = []
```

This is how the standard library writes `some Collection<Int>`.

## Composition over inheritance

```swift
protocol Named { var name: String { get } }
protocol Priced { var price: Double { get } }

typealias Product = Named & Priced

func receiptLine(for item: some Named & Priced) -> String {
    "\(item.name)  \(item.price.formatted(.currency(code: "NGN")))"
}
```

## Dependency injection with protocols

```swift
protocol WeatherService { func temperature(city: String) async throws -> Double }

struct LiveWeather: WeatherService { /* calls the real API */ }
struct MockWeather: WeatherService {
    func temperature(city: String) async throws -> Double { 25 }
}

@Observable final class WeatherViewModel {
    private let service: any WeatherService
    init(service: any WeatherService = LiveWeather()) { self.service = service }
}
```

Tests pass `MockWeather()`, so there are no real network calls.

```quiz
[
 {"q": "What is an associated type?", "options": ["A stored property", "A placeholder type a conforming type specifies", "A subclass", "A generic function"], "answer": 1, "why": "associatedtype lets protocols be generic over a type."},
 {"q": "Why inject protocols instead of concrete types?", "options": ["Speed", "So you can swap in fakes for tests and previews", "Required by Swift", "To avoid optionals"], "answer": 1, "why": "Code depends on behaviour, not one implementation."}
]
```

=== FILE: property-wrappers.md ===
---
title: Property Wrappers & Result Builders
summary: The magic behind @State and SwiftUI's view syntax.
minutes: 8
---
## Property wrappers

A property wrapper reuses get/set logic. `@State`, `@AppStorage` and `@Environment` are all property wrappers.

```swift
@propertyWrapper
struct Clamped {
    private var value: Int
    let range: ClosedRange<Int>

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
}

struct Volume {
    @Clamped(0...100) var level = 50
}

var v = Volume()
v.level = 150
print(v.level)   // 100
```

## Result builders

SwiftUI's `body` is a **result builder** (`@ViewBuilder`): it turns a list of expressions into one value.

```swift
@resultBuilder
struct ListBuilder {
    static func buildBlock(_ parts: String...) -> [String] { parts }
}

func makeList(@ListBuilder _ content: () -> [String]) -> [String] { content() }

let items = makeList {
    "Apples"
    "Bananas"
    "Cherries"
}
```

```swift
@ViewBuilder
func badge(for count: Int) -> some View {
    if count > 0 {
        Text("\(count)").padding(6).background(.red, in: .circle)
    } else {
        EmptyView()
    }
}
```

```quiz
[
 {"q": "Which property must a @propertyWrapper provide?", "options": ["value", "wrappedValue", "projectedValue", "storage"], "answer": 1, "why": "wrappedValue is required; projectedValue ($) is optional."},
 {"q": "What lets SwiftUI's body list several views without commas or return?", "options": ["Macros", "Result builders (@ViewBuilder)", "Closures only", "Generics"], "answer": 1, "why": "Result builders transform the statement list."}
]
```

=== FILE: macros.md ===
---
title: Macros
summary: Compile-time code generation: #Preview, @Observable, @Model and your own.
minutes: 7
---
**Macros** generate code at compile time, removing boilerplate while staying type-checked.

- **Freestanding macros** start with `#`: `#Preview`, `#Predicate`, `#expect`, `#warning("TODO")`.
- **Attached macros** start with `@` and modify a declaration: `@Observable`, `@Model`, `@Test`.

```swift
#warning("Remember to add error handling")

let isDebug: Bool = {
    #if DEBUG
    return true
    #else
    return false
    #endif
}()
```

Right-click a macro in Xcode and choose **Expand Macro** to see the generated code. It's a great way to learn what `@Observable` actually does.

## Writing your own

Custom macros live in a Swift package that depends on **swift-syntax**:

```bash
swift package init --type macro
```

```swift
// Usage of the template's macro:
let (value, code) = #stringify(2 + 3)   // (5, "2 + 3")
```

:::note
Macros can only **add** code (or check it). They can't secretly delete or rewrite what you wrote, which keeps them predictable.
:::

```quiz
[
 {"q": "Which prefix do freestanding macros use?", "options": ["@", "#", "$", "&"], "answer": 1, "why": "Freestanding macros are written like #Preview."},
 {"q": "How can you see what a macro generates?", "options": ["You can't", "Right-click → Expand Macro in Xcode", "Read the binary", "Run the app"], "answer": 1, "why": "Xcode can expand macros inline."}
]
```

=== FILE: noncopyable-ownership.md ===
---
title: Ownership & Noncopyable Types
summary: ~Copyable, consuming and borrowing for advanced performance and safety.
minutes: 8
---
By default every Swift type is **Copyable**. Sometimes a value must have exactly **one owner**: a file handle, a payment token that can be used only once, or a unique resource.

```swift
struct SingleUseTicket: ~Copyable {
    let code: String

    consuming func redeem() -> String {     // using it ends its lifetime
        "Redeemed \(code)"
    }

    deinit { print("Ticket \(code) discarded") }   // noncopyable structs can have deinit
}

let ticket = SingleUseTicket(code: "A1")
print(ticket.redeem())
// print(ticket.redeem())   // ❌ compile error: 'ticket' used after consume
```

## Parameter ownership

```swift
func inspect(_ t: borrowing SingleUseTicket) { print(t.code) }  // read without taking ownership
func store(_ t: consuming SingleUseTicket) { /* takes ownership */ }
```

## Explicit consume

```swift
var bigBuffer = [UInt8](repeating: 0, count: 1_000_000)
let moved = consume bigBuffer     // ends bigBuffer's lifetime: no copy
```

:::note
Most app code never needs this. It matters for systems programming, performance-critical libraries, and APIs that must enforce "use exactly once" at compile time.
:::

```quiz
[
 {"q": "What does ~Copyable mean?", "options": ["Deep copy", "The type can't be implicitly copied: one owner", "Copy on write", "Thread-safe"], "answer": 1, "why": "Noncopyable types have unique ownership."},
 {"q": "What happens after calling a `consuming` method?", "options": ["Nothing", "The value can't be used again", "It's copied", "It becomes nil"], "answer": 1, "why": "Consuming ends the value's lifetime."}
]
```

=== FILE: swift-testing.md ===
---
title: Testing with Swift Testing
summary: @Test, #expect, parameterized tests and async tests.
minutes: 8
---
**Swift Testing** is Apple's modern testing framework (Xcode 16+). It replaces most XCTest boilerplate.

```swift
import Testing
@testable import MyApp

@Suite("Cart")
struct CartTests {
    @Test func startsEmpty() {
        let cart = CartModel()
        #expect(cart.items.isEmpty)
    }

    @Test func totalAddsPrices() {
        let cart = CartModel()
        cart.add(Product(name: "Tea", price: 2.5))
        cart.add(Product(name: "Cake", price: 4))
        #expect(cart.total == 6.5)
    }

    @Test("Rejects invalid emails", arguments: ["", "nope", "a@b"])
    func invalidEmails(_ input: String) {
        #expect(Email(input) == nil)          // runs once per argument
    }

    @Test func loadsPosts() async throws {
        let posts = try await APIClient(session: .mock).get("posts", as: [Post].self)
        try #require(posts.count > 0)          // stops the test if false
        #expect(posts.first?.title == "Hello")
    }

    @Test func throwsWhenEmpty() {
        #expect(throws: ParseError.self) { try parse("") }
    }
}
```

| XCTest | Swift Testing |
|---|---|
| `class FooTests: XCTestCase` | `struct FooTests` (+ `@Suite`) |
| `func testX()` | `@Test func x()` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTUnwrap` | `try #require(...)` |

Run tests with **⌘U** in Xcode, or `swift test` for packages. UI tests still use **XCUITest**.

```quiz
[
 {"q": "Which macro checks a condition in Swift Testing?", "options": ["XCTAssert", "#expect", "@assert", "#check"], "answer": 1, "why": "#expect records a failure if the condition is false."},
 {"q": "How do you run one test with several inputs?", "options": ["Copy it", "@Test(arguments: [...])", "A for loop only", "XCTest"], "answer": 1, "why": "Parameterized tests run once per argument."}
]
```

=== FILE: app-architecture.md ===
---
title: App Architecture & Shipping
summary: MVVM, project structure, performance and the App Store.
minutes: 9
---
## MVVM in SwiftUI

```swift
@Observable
@MainActor
final class PostsViewModel {
    enum State { case idle, loading, loaded([Post]), failed(String) }
    private(set) var state = State.idle
    private let api: any PostsAPI

    init(api: any PostsAPI) { self.api = api }

    func load() async {
        state = .loading
        do { state = .loaded(try await api.posts()) }
        catch { state = .failed(error.localizedDescription) }
    }
}

struct PostsScreen: View {
    @State var model: PostsViewModel
    var body: some View {
        Group {
            switch model.state {
            case .idle, .loading: ProgressView()
            case .loaded(let posts): List(posts) { Text($0.title) }
            case .failed(let message): ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))
            }
        }
        .task { await model.load() }
    }
}
```

**View** = layout only. **ViewModel** = state and logic (testable with no UI). **Model / Services** = data and networking.

## Folder structure

```text
MyApp/
  App/            MyApp.swift, AppDependencies.swift
  Features/
    Posts/        PostsScreen.swift, PostsViewModel.swift
    Settings/
  Services/       APIClient.swift, KeychainStore.swift
  Models/         Post.swift
  Resources/      Assets.xcassets, Localizable.xcstrings
```

## Performance checklist

- Measure with **Instruments** (Time Profiler, SwiftUI, Allocations, Leaks).
- Keep `body` cheap: no heavy work or formatting allocations inside it.
- Use `LazyVStack` and `List` for long content.
- Mark classes `final`; prefer structs.
- Avoid retain cycles in closures (`[weak self]`).

## Shipping to the App Store

1. Join the **Apple Developer Program** ($99/year).
2. Set the bundle ID, version and build number; add an app icon.
3. **Product → Archive** in Xcode, then **Distribute App → App Store Connect**.
4. Test with **TestFlight**, fill in the listing and privacy details, and submit for review.

```quiz
[
 {"q": "In MVVM, where should networking and state logic live?", "options": ["Inside body", "The ViewModel / services", "The asset catalog", "The App struct only"], "answer": 1, "why": "Views stay simple; ViewModels hold testable logic."},
 {"q": "Which tool finds slow code and leaks?", "options": ["Simulator", "Instruments", "TestFlight", "Interface Builder"], "answer": 1, "why": "Instruments profiles CPU, memory, leaks and more."}
]
```
