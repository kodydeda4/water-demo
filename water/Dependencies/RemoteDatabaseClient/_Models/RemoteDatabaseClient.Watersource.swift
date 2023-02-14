import Foundation

extension RemoteDatabaseClient {
  struct Watersource {
    let id: UUID
    let title: String
    let imageURL: URL
    let location: CoordinateLocation
    var boil: Double
    var disinfect: Double
    var filter: Double
  }
}

// MARK: - Protocol Conformance

extension RemoteDatabaseClient.Watersource: Identifiable {}
extension RemoteDatabaseClient.Watersource: Codable {}
extension RemoteDatabaseClient.Watersource: Equatable {}
extension RemoteDatabaseClient.Watersource: Hashable {}
