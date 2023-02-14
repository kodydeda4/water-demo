import SwiftUI
import ComposableArchitecture

struct AppReducer: ReducerProtocol {
  struct State: Equatable {
    var search = Search.State()
  }
  
  enum Action: Equatable {
    case search(Search.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.search, action: /Action.search) {
      Search()
    }
    ._printChanges()
  }
}

// MARK: - SwiftUI

struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    SearchView(store: store.scope(
      state: \.search,
      action: AppReducer.Action.search
    ))
  }
}

// MARK: - SwiftUI Previews

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: Store(
      initialState: AppReducer.State(),
      reducer: AppReducer()
    ))
  }
}
