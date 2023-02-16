import ComposableArchitecture
import XCTest

@testable import water

@MainActor
final class WatersourceDetailsTests: XCTestCase {
  func testBoilButtonTapped() async {
    let store = TestStore(
      initialState: WatersourceDetails.State(model: .testValue),
      reducer: WatersourceDetails()
    ) {
      $0.remoteDatabase.updateWatersource = { _ in }
    }
    await store.send(.boilButtonTapped) {
      $0.model.percentBoiled = 100
    }
    await store.receive(.updateRemoteDatabase)
    await store.receive(.updateRemoteDatabaseResponse(.success("Success")))
  }
  
  func testDisinfectButtonTapped() async {
    let store = TestStore(
      initialState: WatersourceDetails.State(model: .testValue),
      reducer: WatersourceDetails()
    ) {
      $0.remoteDatabase.updateWatersource = { _ in }
    }
    await store.send(.disinfectButtonTapped) {
      $0.model.percentDisinfected = 100
    }
    await store.receive(.updateRemoteDatabase)
    await store.receive(.updateRemoteDatabaseResponse(.success("Success")))
  }
  
  func testFilterButtonTapped() async {
    let store = TestStore(
      initialState: WatersourceDetails.State(model: .testValue),
      reducer: WatersourceDetails()
    ) {
      $0.remoteDatabase.updateWatersource = { _ in }
    }
    await store.send(.filterButtonTapped) {
      $0.model.percentFiltered = 100
    }
    await store.receive(.updateRemoteDatabase)
    await store.receive(.updateRemoteDatabaseResponse(.success("Success")))
  }
  
  func testDidComplete() async {
    let store = TestStore(
      initialState: WatersourceDetails.State(model: .testValue),
      reducer: WatersourceDetails()
    )
    await store.send(.didComplete) {
      $0.destination = .didCompleteAlert(AlertState {
        TextState("Sanitization Complete")
      } actions: {
        ButtonState(role: .cancel) {
          TextState("Dismiss")
        }
      } message: {
        TextState("The water is safe for drinking.")
      })
    }
  }
}

private extension RemoteDatabaseClient.Watersource {
  static var testValue = Self(
    id: UUID(),
    title: "Title",
    imageURL: URL(string: "https://www.google.com")!,
    location: CoordinateLocation(),
    percentBoiled: 0,
    percentDisinfected: 0,
    percentFiltered: 0
  )
}
