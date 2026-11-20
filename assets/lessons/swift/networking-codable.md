---
title: Networking & Codable
summary: Call REST APIs and decode JSON into Swift types.
minutes: 10
---
## Codable

```swift
struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

let json = #"{"id": 1, "userId": 7, "title": "Hello", "body": "First post"}"#.data(using: .utf8)!
let post = try JSONDecoder().decode(Post.self, from: json)
let back = try JSONEncoder().encode(post)
```

## snake_case and custom keys

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase   // published_year -> publishedYear
decoder.dateDecodingStrategy = .iso8601

struct Book: Codable {
    let title: String
    let publishedYear: Int?
    let coverURL: URL?

    enum CodingKeys: String, CodingKey {
        case title, publishedYear
        case coverURL = "cover"              // JSON key "cover"
    }
}
```

## A small API client

```swift
enum APIError: Error { case badStatus(Int) }

struct APIClient {
    var baseURL = URL(string: "https://jsonplaceholder.typicode.com")!

    func get<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: baseURL.appending(path: path))
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else { throw APIError.badStatus(status) }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body) async throws -> T {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

let posts: [Post] = try await APIClient().get("posts")
```

## In a view: loading, loaded, failed

```swift
struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var error: String?

    var body: some View {
        List(posts) { Text($0.title) }
            .overlay { if let error { ContentUnavailableView("Offline", systemImage: "wifi.slash", description: Text(error)) } }
            .task {
                do { posts = try await APIClient().get("posts") }
                catch { self.error = error.localizedDescription }
            }
    }
}
```

:::tip
To send a Laravel Sanctum token, add `request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")`, and store tokens in the **Keychain**, not UserDefaults.
:::

```quiz
[
 {"q": "Which protocol pair does Codable combine?", "options": ["Equatable & Hashable", "Encodable & Decodable", "Sendable & Hashable", "Identifiable & Codable"], "answer": 1, "why": "Codable = Encodable & Decodable."},
 {"q": "How do you map published_year to publishedYear automatically?", "options": ["CodingKeys only", "keyDecodingStrategy = .convertFromSnakeCase", "Rename the JSON", "Use a dictionary"], "answer": 1, "why": "The decoder converts snake_case keys for you."},
 {"q": "Where should auth tokens be stored on iOS?", "options": ["UserDefaults", "The Keychain", "A text file", "The app bundle"], "answer": 1, "why": "The Keychain stores secrets encrypted."}
]
```
