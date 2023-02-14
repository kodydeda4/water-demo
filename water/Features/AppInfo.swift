import SwiftUI
import ComposableArchitecture

struct AppInfo: ReducerProtocol {
  struct State: Equatable {
    //var radar: RadarClient.Radar?
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

private struct HapticProminentButtonStyle: ButtonStyle {
  var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
  
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration
      .label
      .font(.headline)
      .foregroundColor(Color.white)
      .padding(.horizontal)
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity)
      .background(
//        Color(.darkGray)
        Color.accentColor
          .overlay {
            Color.black.opacity(configuration.isPressed ? 0.2 : 0)
          }
      )
      .animation(
        Animation.default.speed(2.0),
        value: configuration.isPressed
      )
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .onChange(of: configuration.isPressed) { isPressed in
        if isPressed {
          UIImpactFeedbackGenerator(style: feedbackStyle)
            .impactOccurred()
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
 
