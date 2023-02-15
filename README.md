# 💧 Water Demo
 
 This demo shows my ideal way of creating iOS apps, including patterns for dependency injection and state management.

 > Each location contains contanimated water that needs to be cleaned. Tapping on any of the locations takes you to a new page where you can clean the water.

<img width="200" alt="A" src="https://user-images.githubusercontent.com/45678211/219173960-f49e57a7-991a-452b-a146-8521a5e6c116.png"><img width="200" alt="A" src="https://user-images.githubusercontent.com/45678211/219173964-5946e8bf-83fd-4400-9c57-4c864ffbd76b.png"><img width="200" alt="A" src="https://user-images.githubusercontent.com/45678211/219173966-fed03fe2-e0f4-4ca9-89b1-6f11d243bf0d.png">


## 1. State Management

 My ideal way of managing state within SwiftUI apps is using [TheComposableArchitecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture). TCA provides excellent documentation examples for how to create features in a consistent and predictable way, and offers tools for modeling and maintaining state.

```swift
struct Feature: ReducerProtocol {
  struct State: Equatable {
    //...
  }
  
  enum Action: Equatable {
    //...
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        //...
      }
    }
  }
}
```

 ## 2. Dependency Injection

Dependencies contain business logic for the app that has to communicate with the outside world (other programs, APIs, databases, etc.)

The preferred way of modeling dependencies in TCA is to create `static` implementations of immutable `structs`, which implement `async` functions as `var`'s, and which are globally available to all `Reducer`'s within the app.

Each implementation serves a unique purpose - they are `preview`, `live`, and `test`.

```swift
struct Client: DependencyKey {
  var fetchData: @Sendable () async throws -> [Data]
}

extension Client {
  static var liveValue = Self.live // used when the app is running
  static var previewValue = Self.mock // used during swiftui previews
  static var testValue = Self.test // used during tests
}
```

## 3. View Composition

In general, I like to make the most out of the pre-built SwiftUI components, and style them as much as possible. This includes things such as `List`, `Form`, `Button`, `Picker`, etc. 

It's not that custom views aren't necessary (they definitley are), but encapsulating and burying the native components too much can cause bugs and make things extremely difficult to bug or understand (unless you wrote those components yourself). 

With TCA, you only need to pass one object to each view (the store), which can be scoped into child states, used to observe properties and send actions back into the system.

```swift
struct FeatureView: View {
  let store: StoreOf<Feature>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStack {
        List {
          Section {
            Button("Perform Task") {
              viewStore.send(.performTask)
            }
          }
        }
        .navigationTitle(viewStore.title)
      }
    }
  }
}
```

## 4. Testing

Above I mentioned there are 3 types of dependenices - `preview`, `live`, and `test`.

The `test` dependencies contain unimplemented functions, which fail the tests immediately unless implemented inside the test iself.

This means you can write tests asserting when A succeeds or fails, and you know exactly which functions need to be implemented for that test to succeed.

```swift
// Definition
extension Dependency {
  static var testValue = Self(
    getAuthor: unimplemented("\(Self.self).getAuthor")
  )
}
```

```swift
// Test
func testTask() async {
  let response = Author()
  let store = TestStore(
    initialState: Feature.State(),
    reducer: Feature()
  ) {
    $0.dependency.getAuthor = { response }
  }
  
  await store.send(.task)
  await store.receive(.taskResponse(.success(response))) {
    $0.author = response
  }
}
```

## 5. Navigation (State-Driven )

Navigation includes things like `Alerts`, `Sheets`, `NavigationLinks`, etc.

Whenever a user can navigate from one page to another, I like to explicitly define them as an `optional enum`. Defining these states as optional and mutually exclusive helps remove bugs like a sheet and alert being present at the same time, and helps with previewing the functionality programmaticly in SwiftUI.

Whenever the enum switches to one of those states, the view routes to the new destination, and unwraps the associated `store` if necessary.

```swift
struct State: Equatable {
  var destination: Destination?
  
  enum Destination: Equatable {
    case signup(Signup.State)
    case forgotPasswordSheet(ForgotPassword.State)
  }
}

enum Action: Equatable {
  case setDestination(Destination?)
  case destination(Destination)
  
  enum Destination: Equatable {
    case signup(Signup.Action)
    case forgotPassword(ForgotPassword.Action)
  }
}
```