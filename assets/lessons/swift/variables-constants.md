---
title: Variables & Constants
summary: let vs var, naming, and why constants are preferred.
minutes: 6
---
```swift
let birthYear = 1990     // constant: can never change
var score = 0            // variable: can change
score += 10
// birthYear = 1991      // ❌ error: cannot assign to a 'let' constant
```

## let first

Use `let` by default and only switch to `var` when the value really must change. Constants make code easier to reason about, and Xcode warns you when a `var` is never changed.

## Type annotations

Swift **infers** types, but you can write them:

```swift
let name: String = "Ada"
var temperature: Double = 21.5
let isOnline: Bool
isOnline = true   // a constant can be assigned once, later
```

## Naming

- `camelCase` for variables, constants and functions: `userName`, `maxRetryCount`.
- `UpperCamelCase` for types: `UserProfile`, `NetworkError`.
- Clear names beat short names: `elapsedSeconds` instead of `t`.

```swift
let 🍕 = "pizza"   // Unicode names work, but please don't 😄
```

```quiz
[
 {"q": "Which keyword declares a constant?", "options": ["var", "let", "const", "final"], "answer": 1, "why": "let declares an immutable value."},
 {"q": "What does Swift recommend by default?", "options": ["var everywhere", "let unless the value must change", "global variables", "implicit types only"], "answer": 1, "why": "Prefer let; use var only when needed."}
]
```
