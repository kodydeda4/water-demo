// swiftlint:disable all
import Amplify
import Foundation

extension WatersourceAWS {
  // MARK: - CodingKeys
  public enum CodingKeys: String, ModelKey {
    case id
    case title
    case imageURL
    case locationLatitude
    case locationLongitude
    case percentBoiled
    case percentDisinfected
    case percentFiltered
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema
  
  public static let schema = defineSchema { model in
    let watersourceAWS = WatersourceAWS.keys
    
    model.pluralName = "WatersourceAWS"
    
    model.attributes(
      .primaryKey(fields: [watersourceAWS.id])
    )
    
    model.fields(
      .field(watersourceAWS.id, is: .required, ofType: .string),
      .field(watersourceAWS.title, is: .required, ofType: .string),
      .field(watersourceAWS.imageURL, is: .required, ofType: .string),
      .field(watersourceAWS.locationLatitude, is: .required, ofType: .double),
      .field(watersourceAWS.locationLongitude, is: .required, ofType: .double),
      .field(watersourceAWS.percentBoiled, is: .required, ofType: .double),
      .field(watersourceAWS.percentDisinfected, is: .required, ofType: .double),
      .field(watersourceAWS.percentFiltered, is: .required, ofType: .double),
      .field(watersourceAWS.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(watersourceAWS.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
  }
}

extension WatersourceAWS: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
