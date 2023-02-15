import Foundation
import ComposableArchitecture

extension AppInfoClient {
  static var live: Self {
    return Self(
      getAuthor: {
        Author(
          name: "Kody Deda",
          title: "iOS Developer",
          avatarURL: URL(string: "https://live.staticflickr.com/65535/51904519089_c6ef9deaff_o.png")!
        )
      }
    )
  }
}
