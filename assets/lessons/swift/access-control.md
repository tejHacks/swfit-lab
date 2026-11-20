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
