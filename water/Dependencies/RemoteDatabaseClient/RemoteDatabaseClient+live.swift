import Amplify
import AWSDataStorePlugin
import Foundation
import ComposableArchitecture

extension RemoteDatabaseClient {
  static var live: Self {
    // Setup
    try? Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
    try? Amplify.configure()
    let store = Amplify.DataStore
    
    return Self(
      getWatersources: {
        try await store.query(WatersourceAWS.self).map(RemoteDatabaseClient.Watersource.init)
      },
      updateWatersource: { model in
        try await store.save(WatersourceAWS(model))
      }
    )
  }
}

// MARK: - Helpers

private extension RemoteDatabaseClient.Watersource {
  init(_ model: WatersourceAWS) {
    self = Self(
      id: UUID(uuidString: model.id)!,
      title: model.title,
      imageURL: URL(string: model.imageURL)!,
      location: CoordinateLocation(
        latitude: model.locationLatitude,
        longitude: model.locationLongitude
      ),
      percentBoiled: model.percentBoiled,
      percentDisinfected: model.percentDisinfected,
      percentFiltered: model.percentFiltered
    )
  }
}

private extension WatersourceAWS {
  init(_ model: RemoteDatabaseClient.Watersource) {
    self = Self(
      id: model.id.uuidString,
      title: model.title,
      imageURL: model.imageURL.description,
      locationLatitude: model.location.latitude.magnitude,
      locationLongitude: model.location.longitude.magnitude,
      percentBoiled: model.percentBoiled,
      percentDisinfected: model.percentDisinfected,
      percentFiltered: model.percentFiltered
    )
  }
}
