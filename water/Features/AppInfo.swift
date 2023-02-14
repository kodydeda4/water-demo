import SwiftUI
import ComposableArchitecture

struct AppInfo: ReducerProtocol {
  struct State: Equatable {
    //...
  }
  
  enum Action: Equatable {
    case dismissButtonTapped
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        
      case .dismissButtonTapped:
        return .none
      }
    }
  }
}

// MARK: - SwiftUI

struct AppInfoView: View {
  let store: StoreOf<AppInfo>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        VStack(spacing: 8) {
          Text("About this Demo")
            .font(.largeTitle)
            .bold()
          
          Text("This demo was created by Kody Deda.")
            .multilineTextAlignment(.center)
        }
        .padding()
        .padding([.horizontal, .top])
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItemGroup(placement: .cancellationAction) {
            Button("Dismiss") {
              viewStore.send(.dismissButtonTapped)
            }
          }
        }
      }
    }
  }
}

// MARK: - SwiftUI Previews

struct AppInfoView_Previews: PreviewProvider {
  static var previews: some View {
    AppInfoView(
      store: Store(
        initialState: AppInfo.State(),
        reducer: AppInfo()
      )
    )
  }
}
 