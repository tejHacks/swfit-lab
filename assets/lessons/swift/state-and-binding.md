---
title: State & Bindings
summary: @State, @Binding and the single source of truth.
minutes: 9
---
## @State: local view state

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("Count: \(count)").font(.largeTitle)
            Button("Add one") { count += 1 }   // changing state re-renders the view
                .buttonStyle(.borderedProminent)
        }
    }
}
```

## @Binding: let a child edit the parent's state

```swift
struct SettingsView: View {
    @State private var notifications = true

    var body: some View {
        NotificationToggle(isOn: $notifications)   // $ creates a binding
    }
}

struct NotificationToggle: View {
    @Binding var isOn: Bool
    var body: some View {
        Toggle("Notifications", isOn: $isOn)
    }
}
```

## Forms

```swift
struct SignUpView: View {
    @State private var email = ""
    @State private var agree = false

    var isValid: Bool { email.contains("@") && agree }

    var body: some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            Toggle("I agree to the terms", isOn: $agree)
            Button("Create account") { }
                .disabled(!isValid)
        }
    }
}
```

:::note
**Single source of truth**: each piece of data should live in exactly one place. Other views receive it read-only or through a `Binding`.
:::

```quiz
[
 {"q": "What does $count create from @State var count?", "options": ["A copy", "A Binding to it", "A publisher", "A string"], "answer": 1, "why": "The $ prefix projects a Binding."},
 {"q": "Who should own @State?", "options": ["Any view", "The view where the state lives (keep it private)", "The App struct only", "A child view"], "answer": 1, "why": "@State is private, view-owned storage."}
]
```
