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
        Form {
          Section("Author") {
            HStack {
              HStack {
                AsyncImage(
                  url: URL(string: "https://live.staticflickr.com/65535/51904519089_c6ef9deaff_o.png")!,
                  content: { $0.resizable().scaledToFit() },
                  placeholder: ProgressView.init
                )
                .frame(width: 60, height: 60)
                .background(Color(.systemFill))
                .clipShape(Circle())
                .padding(.trailing, 4)
                
                VStack(alignment: .leading) {
                  Text("Kody Deda")
                    .font(.title2)
                  Text("iOS Developer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
              }
            }
          }
          Section(
            header: Text("CDC Information"),
            footer: Text("Learn about the different stages of cleaning water and how to make it clean for human consumption. ")
          ) {
            Link(
              "Making Water Safe in an Emergency",
              destination: URL(string: "https://www.cdc.gov/healthywater/emergency/making-water-safe.html")!
            )
          }
          
          Section("About") {
            Text("This demo shows my ideal way of creating iOS apps, including patterns for dependency injection and state management.")
          }
        }
        .navigationTitle("ReadMe")
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

