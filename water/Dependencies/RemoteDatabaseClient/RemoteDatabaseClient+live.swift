import Foundation
import ComposableArchitecture

// TODO: Implement AWS db.
extension RemoteDatabaseClient {
  static var live: Self {
    
    return Self(
      getWatersources: { [] },
      updateWatersource: { _ in }
    )
  }
}
