---
title: Setting Up: Xcode & Playgrounds
summary: Install Xcode, run code instantly in Playgrounds, and create your first app.
minutes: 7
---
## Install Xcode

1. Open the **Mac App Store**, search **Xcode**, install it (it's large: be patient).
2. Open Xcode once so it can install extra components.
3. Optional: install the command-line tools with `xcode-select --install`.

## Three ways to run Swift

**1. Playgrounds:** the fastest way to learn. In Xcode choose **File → New → Playground**. Code runs as you type and results appear in the sidebar.

**2. Terminal:**

```bash
swift --version
echo 'print("Hello from the terminal!")' > hello.swift
swift hello.swift
```

**3. An iOS app:** **File → New → Project → iOS → App**, choose **SwiftUI**, then press **⌘R** to run it in the iPhone Simulator.

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, SwiftUI!")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    ContentView()
}
```

:::tip
`#Preview` shows a live preview of your view in Xcode's canvas. Press **⌥⌘↩** (Option + Command + Return) to show or hide it.
:::

## Useful shortcuts

| Shortcut | Action |
|---|---|
| ⌘R | Build & run |
| ⌘B | Build only |
| ⌘. | Stop |
| ⌘U | Run tests |
| ⌃I | Re-indent selection |
| ⌘/ | Comment / uncomment |
| ⇧⌘O | Open quickly (find any file) |

```quiz
[
 {"q": "What is the quickest way to experiment with Swift code?", "options": ["A full iOS project", "A Playground", "Terminal only", "TestFlight"], "answer": 1, "why": "Playgrounds run your code instantly as you type."},
 {"q": "Which shortcut builds and runs an app in Xcode?", "options": ["⌘B", "⌘R", "⌘U", "⌘P"], "answer": 1, "why": "⌘R builds and runs."}
]
```
