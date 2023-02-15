import SwiftUI
import ComposableArchitecture
import MapKit

struct Search: ReducerProtocol {
  struct State: Equatable {
    var watersources = IdentifiedArrayOf<Watersource.State>()
    var destination: Destination?
    @BindableState var region = CoordinateRegion.wilmington
    
    enum Destination: Equatable {
      case information(Information.State)
      case watersourceDetails(WatersourceDetails.State)
    }
  }
  
  enum Action: BindableAction, Equatable {
    case task
    case taskResponse(TaskResult<[RemoteDatabaseClient.Watersource]>)
    case binding(BindingAction<State>)
    case setDestination(State.Destination?)
    case watersources(id: Watersource.State.ID, action: Watersource.Action)
    case destination(Destination)
    enum Destination: Equatable {
      case information(Information.Action)
      case watersourceDetails(WatersourceDetails.Action)
    }
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
          Watersource.State(model: $0)
        })
        return .none
        
      case .taskResponse(.failure):
        return .none
        
      case .binding:
        return .none
        
      case let .setDestination(value):
        state.destination = value
        return .none
        
      case .watersources:
        return.none
        
      case .destination(.information(.dismissButtonTapped)):
        state.destination = nil
        return .none
        
      case .destination:
        return .none
        
      }
    }
    .forEach(\.watersources, action: /Action.watersources) {
      Watersource()
    }
    .ifLet(\.destination, action: /Action.destination) {
      EmptyReducer()
        .ifCaseLet(/State.Destination.information, action: /Action.Destination.information) { Information() }
        .ifCaseLet(/State.Destination.watersourceDetails, action: /Action.Destination.watersourceDetails) { WatersourceDetails() }
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
                WatersourceNavigationLink(
                  store: store,
                  childStore: childStore
                )
              }
            }
          }
          .task { viewStore.send(.task) }
          .navigationTitle("Search")
          .toolbar {
            Button(action: { viewStore.send(.setDestination(.information(.init()))) }) {
              Image(systemName: "info.circle.fill")
            }
          }
          .sheet(
            isPresented: viewStore.binding(
              get: { CasePath.extract(/Search.State.Destination.information)(from: $0.destination) != nil },
              send: { Search.Action.setDestination($0 ? .information(.init()) : nil) }
            ),
            content: {
              IfLetStore(store
                .scope(state: \.destination, action: Search.Action.destination)
                .scope(state: /Search.State.Destination.information, action: Search.Action.Destination.information)
              ) { InformationView(store: $0) }
            }
          )
        }
      }
    }
  }
}

private struct WatersourceNavigationLink: View {
  let store: StoreOf<Search>
  let childStore: StoreOf<Watersource>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      WithViewStore(childStore) { childViewStore in
        NavigationLink(
          destination: IfLetStore(store
            .scope(state: \.destination, action: Search.Action.destination)
            .scope(state: /Search.State.Destination.watersourceDetails, action: Search.Action.Destination.watersourceDetails)
          ) { WatersourceDetailsView(store: $0) },
          tag: childViewStore.id,
          selection: viewStore.binding(
            get: { CasePath.extract(/Search.State.Destination.watersourceDetails)(from: $0.destination)?.model.id },
            send: {
              Search.Action.setDestination(viewStore
                .watersources[id: childViewStore.id]
                .flatMap({ Search.State.Destination.watersourceDetails(WatersourceDetails.State(model: $0.model)) })
              )}()
          ),
          label: {
            WatersourceView(store: childStore)
          }
        )
        .buttonStyle(.plain)
        //.listRowBackground(EmptyView())
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
          MapAnnotation(coordinate: watersource.model.location.rawValue) {
            IfLetStore(store.scope(
              state: { $0.watersources[id: watersource.id] },
              action: { Search.Action.watersources(id: watersource.id, action: $0) }
            ), then: WatersourceMapAnnotationView.init)
          }
        }
      )
    }
  }
}

private struct WatersourceMapAnnotationView: View {
  let store: StoreOf<Watersource>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationLink(
        destination: {
          Text("A")
          //WatersourceDetailsView(store: store)
        },
        label: {
          AsyncImage(
            url: viewStore.model.imageURL,
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


// MARK: - SwiftUI Previews

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView(store: Store(
      initialState: Search.State(
        destination: .information(.init())
//        destination: .watersourceDetails(.init(model: .init(
//          id: UUID(),
//          title: "Well A",
//          imageURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.totalsoftwater.com%2Fwp-content%2Fuploads%2F2017%2F08%2Fwells-2212974_1280-180x180.jpg&f=1&nofb=1&ipt=c03b5b92cac7fcf82b6d57cdb22d5df0f9d7d319278cb7278a8beeb32e335a6f&ipo=images")!,
//          location: CoordinateLocation(
//            latitude: Double.random(in: 31..<35),
//            longitude: Double.random(in: -79 ..< -76)
//          ),
//          boil: 59,
//          disinfect: 12,
//          filter: 42
//        )))
      ),
      reducer: Search()
    ))
  }
}
