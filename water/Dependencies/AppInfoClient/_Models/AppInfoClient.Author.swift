import Foundation

extension AppInfoClient {
  struct Author {
    let name: String
    let title: String
    let avatarURL: URL
  }
}

// MARK: - Protocol Conformance

extension AppInfoClient.Author: Codable {}
extension AppInfoClient.Author: Equatable {}
extension AppInfoClient.Author: Hashable {}
