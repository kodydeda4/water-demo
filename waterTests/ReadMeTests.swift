import ComposableArchitecture
import XCTest

@testable import water

@MainActor
final class ReadMeTests: XCTestCase {
  func testTaskSuccess() async {
    let response = AppInfoClient.Author(
      name: "Kody Deda",
      title: "iOS Developer",
      avatarURL: URL(string: "https://www.google.com")!
    )
    let store = TestStore(
      initialState: ReadMe.State(),
      reducer: ReadMe()
    ) {
      
      $0.appInfo.getAuthor = { response }
    }
    
    await store.send(.task)
    await store.receive(.taskResponse(.success(response))) {
      $0.author = response
    }
  }
  
  func testTaskFailure() async {
    struct Failure: Equatable, Error {}
    let response = Failure()
    let store = TestStore(
      initialState: ReadMe.State(),
      reducer: ReadMe()
    ) {
      $0.appInfo.getAuthor = { throw response }
    }
    
    await store.send(.task)
    await store.receive(.taskResponse(.failure(response)))
  }
}
