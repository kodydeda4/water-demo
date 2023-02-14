import SwiftUI
import ComposableArchitecture
import MapKit

struct Search: ReducerProtocol {
  struct State: Equatable {
    var watersources = IdentifiedArrayOf<Watersource.State>()
    var appInfo: AppInfo.State?
    var isAppInfoSheetPresented: Bool { appInfo != nil }
    @BindableState var region = CoordinateRegion.wilmington
  }
  
  enum Action: BindableAction, Equatable {
    case task
    case taskResponse(TaskResult<[RemoteDatabaseClient.Watersource]>)
    case setAppInfoSheet(isPresented: Bool)
    case binding(BindingAction<State>)
    case appInfo(AppInfo.Action)
    case watersources(id: Watersource.State.ID, action: Watersource.Action)
  }
  
  @Dependency(\.remoteDatabase) var remoteDatabase
  
  var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        
      case .task:
        return .task {
          await .taskResponse(TaskResult {
            try await remoteDatabase.getWatersources()
          })
        }
        
      case let .taskResponse(.success(values)):
        state.watersources = .init(uniqueElements: values.map {
          Watersource.State(
            id: $0.id,
            title: $0.title,
            imageURL: $0.imageURL,
            location: $0.location,
            boil: $0.boil,
            disinfect: $0.disinfect,
            filter: $0.filter
          )
        })
        return .none
        
      case .taskResponse(.failure):
        return .none
        
      case .setAppInfoSheet(isPresented: true):
        state.appInfo = .init()
        return .none
        
      case .setAppInfoSheet(isPresented: false):
        state.appInfo = nil
        return .none
        
      case .binding:
        return .none
        
      case .appInfo(.dismissButtonTapped):
        return .send(.setAppInfoSheet(isPresented: false))
        
      case .appInfo:
        return .none
        
      case .watersources:
        return.none
        
      }
    }
    .forEach(\.watersources, action: /Action.watersources) {
      Watersource()
    }
    .ifLet(\.appInfo, action: /Action.appInfo) {
      AppInfo()
    }
    ._printChanges()
  }
}

extension CoordinateRegion {
  static let wilmington = Self(
    location: .init(latitude: 34.125727, longitude: -77.874710),
    span: .init(latitudeDelta: 8, longitudeDelta: 8)
  )
}


// MARK: - SwiftUI

struct SearchView: View {
  let store: StoreOf<Search>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStack {
        VStack {
          Section {
            MapView(store: store)
              .frame(height: 225)
          }
          //.disabled(true)
          .buttonStyle(.plain)
          
          List {
            Section("Search Results") {
              ForEachStore(store.scope(
                state: \.watersources,
                action: Search.Action.watersources
              )) { childStore in
                WithViewStore(childStore) { childViewStore in
                  NavigationLink(
                    destination: {
                      SearchResultDetailsView(store: childStore)
                    },
                    label: {
                      SearchResultView(store: childStore)
                        .padding(.vertical, 2)
                    }
                  )
                }
              }
            }
          }
        }
        .task { viewStore.send(.task) }
        .navigationTitle("Search")
        .toolbar {
          Button(action: { viewStore.send(.setAppInfoSheet(isPresented: true)) }) {
            Image(systemName: "info.circle.fill")
          }
        }
        .sheet(
          isPresented: viewStore.binding(
            get: \.isAppInfoSheetPresented,
            send: Search.Action.setAppInfoSheet(isPresented:)
          ),
          content: {
            IfLetStore(store.scope(
              state: \.appInfo,
              action: Search.Action.appInfo
            ), then: AppInfoView.init)
          }
        )
      }
    }
  }
}

private struct MapView: View {
  let store: StoreOf<Search>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      Map(
        coordinateRegion: .init(
          get: { viewStore.region.rawValue },
          set: { viewStore.send(.binding(.set(\.$region, .init(rawValue: $0)))) }
        ),
        showsUserLocation: true,
        annotationItems: viewStore.watersources,
        annotationContent: { watersource in
          MapAnnotation(coordinate: watersource.location.rawValue) {
            IfLetStore(store.scope(
              state: { $0.watersources[id: watersource.id] },
              action: { Search.Action.watersources(id: watersource.id, action: $0) }
            ), then: EachContent.init)
          }
        }
      )
    }
  }
  
  private struct EachContent: View {
    let store: StoreOf<Watersource>
    
    var body: some View {
      WithViewStore(store) { viewStore in
        NavigationLink(
          destination: {
            SearchResultDetailsView(store: store)
          },
          label: {
            AsyncImage(
              url: viewStore.imageURL,
              content: { $0.resizable().scaledToFill() },
              placeholder: { ProgressView() }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .frame(width: 60)
            .clipShape(Circle())
            .shadow(radius: 2)
          }
        )
      }
    }
  }
}



// MARK: - SwiftUI Previews

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView(store: Store(
      initialState: Search.State(),
      reducer: Search()
    ))
  }
}
