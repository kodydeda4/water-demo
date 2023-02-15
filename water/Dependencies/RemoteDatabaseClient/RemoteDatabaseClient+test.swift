import ComposableArchitecture

extension RemoteDatabaseClient {
  static var test = Self(
    getWatersources: unimplemented("\(Self.self).getWatersouces"),
    updateWatersource: unimplemented("\(Self.self).updateWatersouces")
  )
}
