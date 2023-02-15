import ComposableArchitecture
import XCTest

@testable import water

@MainActor
final class AppReducerTests: XCTestCase {
  func testTask() async {
    let store = TestStore(
      initialState: AppReducer.State(region: .init()),
      reducer: AppReducer()
    )
  }
}
