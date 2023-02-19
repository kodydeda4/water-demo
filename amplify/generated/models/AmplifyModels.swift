// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "6bcba98e6e1f73544d567b81a15df76f"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: WatersourceAWS.self)
  }
}