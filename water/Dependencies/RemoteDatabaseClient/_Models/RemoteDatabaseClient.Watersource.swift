import Foundation

extension RemoteDatabaseClient {
  struct Watersource {
    let id: UUID
    let title: String
    let imageURL: URL
    let location: CoordinateLocation
    var percentBoiled: Double
    var percentDisinfected: Double
    var percentFiltered: Double
  }
}

// MARK: - Protocol Conformance

extension RemoteDatabaseClient.Watersource: Identifiable {}
extension RemoteDatabaseClient.Watersource: Codable {}
extension RemoteDatabaseClient.Watersource: Equatable {}
extension RemoteDatabaseClient.Watersource: Hashable {}

extension RemoteDatabaseClient.Watersource {
  static let mock = Self(
    id: UUID(),
    title: "Well A",
    imageURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.totalsoftwater.com%2Fwp-content%2Fuploads%2F2017%2F08%2Fwells-2212974_1280-180x180.jpg&f=1&nofb=1&ipt=c03b5b92cac7fcf82b6d57cdb22d5df0f9d7d319278cb7278a8beeb32e335a6f&ipo=images")!,
    location: CoordinateLocation(
      latitude: Double.random(in: 31..<35),
      longitude: Double.random(in: -79 ..< -76)
    ),
    percentBoiled: 59,
    percentDisinfected: 12,
    percentFiltered: 42
  )
}

