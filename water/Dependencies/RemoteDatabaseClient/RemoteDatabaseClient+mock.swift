import Foundation
import ComposableArchitecture

extension RemoteDatabaseClient {
  static var mock: Self {
    let db = DatabaseMock()
    
    return Self(
      getWatersources: {
        await db.watersources.elements
      },
      updateWatersource: {
        try await db.update(watersource: $0)
      }
    )
  }
}

// MARK: - Private
private extension RemoteDatabaseClient {
  private actor DatabaseMock {
    var watersources: IdentifiedArrayOf<Watersource>
    
    func update(watersource: Watersource) async throws {
      self.watersources.updateOrAppend(watersource)
    }
    
    init() {
      self.watersources = [
        .init(
          id: UUID(),
          title: "Watersource A",
          imageURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.totalsoftwater.com%2Fwp-content%2Fuploads%2F2017%2F08%2Fwells-2212974_1280-180x180.jpg&f=1&nofb=1&ipt=c03b5b92cac7fcf82b6d57cdb22d5df0f9d7d319278cb7278a8beeb32e335a6f&ipo=images")!,
          location: CoordinateLocation(
            latitude: .random(in: 31..<35),
            longitude: .random(in: -79 ..< -76)
          ),
          percentBoiled: 100,
          percentDisinfected: 54,
          percentFiltered: 0
        ),
        .init(
          id: UUID(),
          title: "Watersource B",
          imageURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthumbs.dreamstime.com%2Ft%2Fold-water-well-pulley-bucket-49458732.jpg&f=1&nofb=1&ipt=a5aaa3217ad64ed51651d8e190c34096e7faa63735442a6e3142148ba0947d9a&ipo=images")!,
          location: CoordinateLocation(
            latitude: .random(in: 31..<35),
            longitude: .random(in: -79 ..< -76)
          ),
          percentBoiled: 0,
          percentDisinfected: 0,
          percentFiltered: 0
        ),
        .init(
          id: UUID(),
          title: "Watersource C",
          imageURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthumbs.dreamstime.com%2Ft%2Fdraw-water-well-various-objects-spring-season-best-wonderful-period-81954677.jpg&f=1&nofb=1&ipt=315b61c3a08f09f3b5a53b8f2691ce1448231a3cb7b5d9512ea41b215a8b6855&ipo=images")!,
          location: CoordinateLocation(
            latitude: .random(in: 31..<35),
            longitude: .random(in: -79 ..< -76)
          ),
          percentBoiled: 0,
          percentDisinfected: 0,
          percentFiltered: 0
        )
      ]
    }
  }
}
