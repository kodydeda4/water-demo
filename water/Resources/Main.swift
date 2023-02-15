import SwiftUI
import ComposableArchitecture

@main
struct Main: App {
  var body: some Scene {
    WindowGroup {
      AppView(store: Store(
        initialState: AppReducer.State(
          region: .init(
            location: .init(latitude: 34.125727, longitude: -77.874710),
            span: .init(latitudeDelta: 8, longitudeDelta: 8)
          )
        ),
        reducer: AppReducer()
      ))
    }
  }
}
