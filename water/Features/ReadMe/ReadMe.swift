import SwiftUI
import ComposableArchitecture

struct ReadMe: ReducerProtocol {
  struct State: Equatable {
    var author: AppInfoClient.Author?
  }
  
  enum Action: Equatable {
    case task
    case taskResponse(TaskResult<AppInfoClient.Author>)
    case dismissButtonTapped
  }
  
  @Dependency(\.appInfo) var appInfo
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        
      case .task:
        return .task {
          await .taskResponse(TaskResult {
            try await appInfo.getAuthor()
          })
        }
        
      case let .taskResponse(.success(value)):
        state.author = value
        return .none
        
      case .taskResponse(.failure):
        return .none
        
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
                  url: viewStore.author?.avatarURL,
                  content: { $0.resizable().scaledToFit() },
                  placeholder: ProgressView.init
                )
                .frame(width: 60, height: 60)
                .background(Color(.systemFill))
                .clipShape(Circle())
                .padding(.trailing, 4)
                
                VStack(alignment: .leading) {
                  Text("\(viewStore.author?.name ?? "--")")
                    .font(.title2)
                  Text("\(viewStore.author?.title ?? "--")")
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
        .task { viewStore.send(.task) }
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

