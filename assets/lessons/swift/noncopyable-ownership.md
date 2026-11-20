---
title: Ownership & Noncopyable Types
summary: ~Copyable, consuming and borrowing for advanced performance and safety.
minutes: 8
---
By default every Swift type is **Copyable**. Sometimes a value must have exactly **one owner**: a file handle, a payment token that can be used only once, or a unique resource.

```swift
struct SingleUseTicket: ~Copyable {
    let code: String

    consuming func redeem() -> String {     // using it ends its lifetime
        "Redeemed \(code)"
    }

    deinit { print("Ticket \(code) discarded") }   // noncopyable structs can have deinit
}

let ticket = SingleUseTicket(code: "A1")
print(ticket.redeem())
// print(ticket.redeem())   // ❌ compile error: 'ticket' used after consume
```

## Parameter ownership

```swift
func inspect(_ t: borrowing SingleUseTicket) { print(t.code) }  // read without taking ownership
func store(_ t: consuming SingleUseTicket) { /* takes ownership */ }
```

## Explicit consume

```swift
var bigBuffer = [UInt8](repeating: 0, count: 1_000_000)
let moved = consume bigBuffer     // ends bigBuffer's lifetime: no copy
```

:::note
Most app code never needs this. It matters for systems programming, performance-critical libraries, and APIs that must enforce "use exactly once" at compile time.
:::

```quiz
[
 {"q": "What does ~Copyable mean?", "options": ["Deep copy", "The type can't be implicitly copied: one owner", "Copy on write", "Thread-safe"], "answer": 1, "why": "Noncopyable types have unique ownership."},
 {"q": "What happens after calling a `consuming` method?", "options": ["Nothing", "The value can't be used again", "It's copied", "It becomes nil"], "answer": 1, "why": "Consuming ends the value's lifetime."}
]
```
