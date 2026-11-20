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
