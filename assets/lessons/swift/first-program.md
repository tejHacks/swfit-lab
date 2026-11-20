---
title: Your First Swift Program
summary: print, comments, and how Swift code is structured.
minutes: 5
---
```swift
print("Hello, Swift!")
print("I am learning", "Swift", separator: " ✨ ")
```

- `print(...)` writes text to the console.
- Swift needs **no semicolons** at the end of lines (you can use them to put two statements on one line).
- In a Playground or script, top-level code runs from top to bottom. In apps, code runs from an entry point marked `@main`.

## Comments

```swift
// A single-line comment

/* A multi-line
   comment */

/// A documentation comment: shows up in Xcode's Quick Help (⌥-click).
func greet() {}
```

## String interpolation

Put values inside text with `\( )`:

```swift
let name = "Ada"
let age = 36
print("\(name) is \(age) years old. Next year she'll be \(age + 1).")
```

:::tip
Practise every example yourself in a Playground. Typing code (not copy-pasting) is how it sticks.
:::

```quiz
[
 {"q": "How do you insert a value into a string in Swift?", "options": ["${value}", "\\(value)", "{value}", "%value"], "answer": 1, "why": "Swift uses \\( ) for string interpolation."},
 {"q": "Do Swift statements need semicolons?", "options": ["Always", "No, only to separate statements on one line", "Only in classes", "Only in playgrounds"], "answer": 1, "why": "Semicolons are optional in Swift."}
]
```
