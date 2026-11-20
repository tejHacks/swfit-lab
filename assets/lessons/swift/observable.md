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
