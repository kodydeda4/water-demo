import ComposableArchitecture

extension AppInfoClient {
  static var test = Self(
    getAuthor: unimplemented("\(Self.self).getAuthor")
  )
}
