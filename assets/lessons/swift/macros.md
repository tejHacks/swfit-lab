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
