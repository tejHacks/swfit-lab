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
