---
title: Strings & Characters
summary: Working with text, multi-line strings and Unicode.
minutes: 7
---
```swift
var greeting = "Hello"
greeting += ", world"
greeting.append("!")

greeting.count                 // 13
greeting.isEmpty               // false
greeting.uppercased()          // "HELLO, WORLD!"
greeting.contains("world")     // true
greeting.hasPrefix("Hell")     // true
greeting.replacingOccurrences(of: "world", with: "Swift")
greeting.split(separator: ",") // ["Hello", " world!"]
"  trim me  ".trimmingCharacters(in: .whitespaces)
```

## Multi-line strings

```swift
let poem = """
    Roses are red,
    Swift is fast,
    Optionals keep
    your crashes past.
    """
```

## Unicode-correct by design

```swift
let flag = "🇳🇬"
flag.count        // 1 (one visible character, though it's several Unicode scalars)

for ch in "Café" { print(ch) }   // C a f é
```

Because characters can have different sizes, you can't use `text[3]`. Use indices:

```swift
let word = "Swift"
let third = word[word.index(word.startIndex, offsetBy: 2)]   // "i"
let firstThree = String(word.prefix(3))                     // "Swi"
```

## Raw strings

```swift
let regexText = #"\d+ apples"#     // backslashes are literal
```

```quiz
[
 {"q": "What is \"🇳🇬\".count?", "options": ["1", "2", "4", "8"], "answer": 0, "why": "Swift counts user-visible characters (grapheme clusters)."},
 {"q": "Why can't you write text[3] on a Swift String?", "options": ["Strings are immutable", "Characters can have different sizes, so Swift uses String.Index", "It's slow", "Strings are arrays"], "answer": 1, "why": "Indices respect Unicode boundaries."}
]
```
