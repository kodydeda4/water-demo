// swiftlint:disable all
import Amplify
import Foundation

public struct WatersourceAWS: Model {
  public let id: String
  public var title: String
  public var imageURL: String
  public var locationLatitude: Double
  public var locationLongitude: Double
  public var percentBoiled: Double
  public var percentDisinfected: Double
  public var percentFiltered: Double
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      title: String,
      imageURL: String,
      locationLatitude: Double,
      locationLongitude: Double,
      percentBoiled: Double,
      percentDisinfected: Double,
      percentFiltered: Double) {
    self.init(id: id,
      title: title,
      imageURL: imageURL,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      percentBoiled: percentBoiled,
      percentDisinfected: percentDisinfected,
      percentFiltered: percentFiltered,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      title: String,
      imageURL: String,
      locationLatitude: Double,
      locationLongitude: Double,
      percentBoiled: Double,
      percentDisinfected: Double,
      percentFiltered: Double,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.title = title
      self.imageURL = imageURL
      self.locationLatitude = locationLatitude
      self.locationLongitude = locationLongitude
      self.percentBoiled = percentBoiled
      self.percentDisinfected = percentDisinfected
      self.percentFiltered = percentFiltered
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}