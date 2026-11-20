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
