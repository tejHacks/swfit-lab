---
title: Error Handling
summary: throws, do/try/catch, typed throws and Result.
minutes: 9
---
```swift
enum WithdrawalError: Error {
    case insufficientFunds(needed: Double)
    case accountLocked
}

struct Account {
    var balance: Double
    var locked = false

    mutating func withdraw(_ amount: Double) throws {
        guard !locked else { throw WithdrawalError.accountLocked }
        guard amount <= balance else {
            throw WithdrawalError.insufficientFunds(needed: amount - balance)
        }
        balance -= amount
    }
}

var account = Account(balance: 50)
do {
    try account.withdraw(80)
} catch WithdrawalError.insufficientFunds(let needed) {
    print("You need \(needed) more")
} catch {
    print("Something else went wrong: \(error)")
}
```

## try? and try!

```swift
let data = try? Data(contentsOf: url)       // nil on failure
let config = try! loadBundledConfig()       // crash on failure: only if impossible
```

## Typed throws (Swift 6)

```swift
func parse(_ text: String) throws(ParseError) -> Int {
    guard let n = Int(text) else { throw .notANumber }
    return n
}

do {
    let n = try parse("x")
} catch {
    // `error` is ParseError here, not `any Error`
}
```

## Result

```swift
func fetchUser(id: Int) -> Result<User, NetworkError> { ... }

switch fetchUser(id: 1) {
case .success(let user): print(user.name)
case .failure(let error): print(error)
}
```

## defer

```swift
func process(file: FileHandle) throws {
    defer { try? file.close() }     // runs however the function exits
    // ...
}
```

```quiz
[
 {"q": "What does try? return when the call throws?", "options": ["Crashes", "nil", "The error", "false"], "answer": 1, "why": "try? converts errors into nil."},
 {"q": "What do typed throws (Swift 6) give you?", "options": ["Faster code only", "The catch block knows the exact error type", "No need for try", "Automatic retries"], "answer": 1, "why": "throws(MyError) makes the error type concrete."},
 {"q": "When does a defer block run?", "options": ["Immediately", "When the current scope exits", "Only on errors", "On app launch"], "answer": 1, "why": "defer runs on scope exit, however you leave."}
]
```
