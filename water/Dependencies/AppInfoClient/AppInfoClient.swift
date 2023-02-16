import Foundation
import ComposableArchitecture

struct AppInfoClient: DependencyKey {
  var getAuthor: @Sendable () async throws -> Author
}

extension DependencyValues {
  var appInfo: AppInfoClient {
    get { self[AppInfoClient.self] }
    set { self[AppInfoClient.self] = newValue }
  }
}

// MARK: - Implementations

extension AppInfoClient {
  static var liveValue = Self.live
  static var previewValue = Self.preview
  static var testValue = Self.test
}
