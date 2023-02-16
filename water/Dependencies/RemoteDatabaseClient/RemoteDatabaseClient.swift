import Foundation
import ComposableArchitecture

struct RemoteDatabaseClient: DependencyKey {
  var getWatersources: @Sendable () async throws -> [Watersource]
  var updateWatersource: @Sendable (Watersource) async throws -> Void
  
  struct Failure: Equatable, Error {}
}

extension DependencyValues {
  var remoteDatabase: RemoteDatabaseClient {
    get { self[RemoteDatabaseClient.self] }
    set { self[RemoteDatabaseClient.self] = newValue }
  }
}

// MARK: - Implementations

extension RemoteDatabaseClient {
  static var liveValue = Self.live
  static var previewValue = Self.preview
  static var testValue = Self.test
}
