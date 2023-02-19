import Amplify
import AWSDataStorePlugin
import Foundation
import ComposableArchitecture

extension RemoteDatabaseClient {
  static var live: Self {
    // Setup Amplify
    try? Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
    try? Amplify.configure()
    
    return Self(
      getWatersources: {
        try await Amplify.DataStore.query(WatersourceAWS.self)
          .map {
            .init(
              id: UUID(uuidString: $0.id)!,
              title: $0.title,
              imageURL: URL(string: $0.imageURL)!,
              location: CoordinateLocation(
                latitude: $0.locationLatitude,
                longitude: $0.locationLongitude
              ),
              percentBoiled: $0.percentBoiled,
              percentDisinfected: $0.percentDisinfected,
              percentFiltered: $0.percentFiltered
            )
          }
      },
      updateWatersource: { model in
        try await Amplify.DataStore.save(WatersourceAWS(
          id: model.id.uuidString,
          title: model.title,
          imageURL: model.imageURL.description,
          locationLatitude: model.location.latitude.magnitude,
          locationLongitude: model.location.longitude.magnitude,
          percentBoiled: model.percentBoiled,
          percentDisinfected: model.percentDisinfected,
          percentFiltered: model.percentFiltered
        ))
      }
    )
  }
}
