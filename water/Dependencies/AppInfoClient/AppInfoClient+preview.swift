import Foundation
import ComposableArchitecture

extension AppInfoClient {
  static var preview: Self {
    return Self(
      getAuthor: {
        Author(
          name: "Johnny Appleseed",
          title: "Preview Author",
          avatarURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2F1.bp.blogspot.com%2F-ppT3QD3BNZE%2FUM4I0O0cNWI%2FAAAAAAAABlw%2F7TUyyAgsCYo%2Fs1600%2Fapple%2Blogo.png&f=1&nofb=1&ipt=ca107f723f620bc54f5e82158fe4ccc28ee219074d2f0a2ad33e5f4ca70773d9&ipo=images")!
        )
      }
    )
  }
}
