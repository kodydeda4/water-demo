import SwiftUI
import ComposableArchitecture
import MapKit

// [CDC] Making Water Safe in an Emergency
//https://www.cdc.gov/healthywater/emergency/making-water-safe.html

struct Search: ReducerProtocol {
  struct State: Equatable {
    var searchResults = IdentifiedArrayOf<SearchResult.State>()
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
    case searchResults(id: SearchResult.State.ID, action: SearchResult.Action)
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
        state.searchResults = .init(uniqueElements: values.map {
          SearchResult.State(
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
        
      case .searchResults:
        return.none
        
      }
    }
    .forEach(\.searchResults, action: /Action.searchResults) {
      SearchResult()
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
  let store: StoreOf<Search> = .init(
    initialState: Search.State(),
    reducer: Search()
  )
  
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
                state: \.searchResults,
                action: Search.Action.searchResults
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
        annotationItems: viewStore.searchResults,
        annotationContent: { searchResult in
          MapAnnotation(coordinate: searchResult.location.rawValue) {
            IfLetStore(store.scope(
              state: { $0.searchResults[id: searchResult.id] },
              action: { Search.Action.searchResults(id: searchResult.id, action: $0) }
            ), then: EachContent.init)
          }
        }
      )
    }
  }
  
  private struct EachContent: View {
    let store: StoreOf<SearchResult>
    
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
    SearchView()
  }
}
