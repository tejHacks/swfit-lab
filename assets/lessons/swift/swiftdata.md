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
