---
title: Testing with Swift Testing
summary: @Test, #expect, parameterized tests and async tests.
minutes: 8
---
**Swift Testing** is Apple's modern testing framework (Xcode 16+). It replaces most XCTest boilerplate.

```swift
import Testing
@testable import MyApp

@Suite("Cart")
struct CartTests {
    @Test func startsEmpty() {
        let cart = CartModel()
        #expect(cart.items.isEmpty)
    }

    @Test func totalAddsPrices() {
        let cart = CartModel()
        cart.add(Product(name: "Tea", price: 2.5))
        cart.add(Product(name: "Cake", price: 4))
        #expect(cart.total == 6.5)
    }

    @Test("Rejects invalid emails", arguments: ["", "nope", "a@b"])
    func invalidEmails(_ input: String) {
        #expect(Email(input) == nil)          // runs once per argument
    }

    @Test func loadsPosts() async throws {
        let posts = try await APIClient(session: .mock).get("posts", as: [Post].self)
        try #require(posts.count > 0)          // stops the test if false
        #expect(posts.first?.title == "Hello")
    }

    @Test func throwsWhenEmpty() {
        #expect(throws: ParseError.self) { try parse("") }
    }
}
```

| XCTest | Swift Testing |
|---|---|
| `class FooTests: XCTestCase` | `struct FooTests` (+ `@Suite`) |
| `func testX()` | `@Test func x()` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTUnwrap` | `try #require(...)` |

Run tests with **⌘U** in Xcode, or `swift test` for packages. UI tests still use **XCUITest**.

```quiz
[
 {"q": "Which macro checks a condition in Swift Testing?", "options": ["XCTAssert", "#expect", "@assert", "#check"], "answer": 1, "why": "#expect records a failure if the condition is false."},
 {"q": "How do you run one test with several inputs?", "options": ["Copy it", "@Test(arguments: [...])", "A for loop only", "XCTest"], "answer": 1, "why": "Parameterized tests run once per argument."}
]
```
