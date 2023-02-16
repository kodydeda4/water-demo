import ComposableArchitecture
import XCTest

@testable import water

@MainActor
final class AppReducerTests: XCTestCase {
  func testTaskSuccess() async {
    let response = [RemoteDatabaseClient.Watersource]([
      .init(
        id: UUID(),
        title: "Title",
        imageURL: URL(string: "https://www.google.com")!,
        location: CoordinateLocation(),
        percentBoiled: 100,
        percentDisinfected: 100,
        percentFiltered: 100
      )
    ])
    let store = TestStore(
      initialState: AppReducer.State(region: .init()),
      reducer: AppReducer()
    ) {
      $0.remoteDatabase.getWatersources = { response }
    }
    await store.send(.task)
    await store.receive(.taskResponse(.success(response))) {
      $0.watersources = .init(uniqueElements: response.map {
        Watersource.State(model: $0)
      })
    }
  }
  
  func testTaskFailure() async {
    struct Failure: Equatable, Error {}
    let response = Failure()
    
    let store = TestStore(
      initialState: AppReducer.State(region: .init()),
      reducer: AppReducer()
    ) {
      $0.remoteDatabase.getWatersources = { throw response }
    }
    await store.send(.task)
    await store.receive(.taskResponse(.failure(response)))
  }
  
  func testSetDestination() {
    let store = TestStore(
      initialState: AppReducer.State(region: .init()),
      reducer: AppReducer()
    )
    let destination = AppReducer.State.Destination.readme(ReadMe.State())
    store.send(.setDestination(destination)) {
      $0.destination = destination
    }
  }
  
  func testReadMeDelegateDismissed() {
    let store = TestStore(
      initialState: AppReducer.State(
        region: .init(),
        destination: .readme(.init())
      ),
      reducer: AppReducer()
    )
    store.send(.destination(.readme(.delegate(.dismissButtonTapped)))) {
      $0.destination = nil
    }
  }
}
