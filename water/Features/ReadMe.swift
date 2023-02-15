import SwiftUI
import ComposableArchitecture

struct ReadMe: ReducerProtocol {
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

struct ReadMeView: View {
  let store: StoreOf<ReadMe>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        VStack(spacing: 8) {
          Text("Kody Deda")
            .font(.largeTitle)
            .bold()
          
          Text("This demo was created by Kody Deda.")
            .multilineTextAlignment(.center)
        }
        .padding()
        .padding([.horizontal, .top])
        .navigationTitle("About")
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

struct ReadMeView_Previews: PreviewProvider {
  static var previews: some View {
    ReadMeView(
      store: Store(
        initialState: ReadMe.State(),
        reducer: ReadMe()
      )
    )
  }
}

