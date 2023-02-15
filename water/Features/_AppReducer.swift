import SwiftUI
import ComposableArchitecture
import MapKit

struct AppReducer: ReducerProtocol {
  struct State: Equatable {
    @BindingState var region: CoordinateRegion
    var watersources = IdentifiedArrayOf<Watersource.State>()
    var destination: Destination?
    
    enum Destination: Equatable {
      case readme(ReadMe.State)
      case watersourceDetails(WatersourceDetails.State)
    }
  }
  
  enum Action: BindableAction, Equatable {
    case task
    case taskResponse(TaskResult<[RemoteDatabaseClient.Watersource]>)
    case setDestination(State.Destination?)
    case binding(BindingAction<State>)
    case watersources(id: Watersource.State.ID, action: Watersource.Action)
    case destination(Destination)
    
    enum Destination: Equatable {
      case readme(ReadMe.Action)
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
        
      case let .setDestination(value):
        state.destination = value
        return .none
        
      case .binding:
        return .none
        
      case .watersources:
        return.none
        
      case .destination(.readme(.dismissButtonTapped)):
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
        .ifCaseLet(/State.Destination.readme, action: /Action.Destination.readme) { ReadMe() }
        .ifCaseLet(/State.Destination.watersourceDetails, action: /Action.Destination.watersourceDetails) { WatersourceDetails() }
    }
    ._printChanges()
  }
}



// MARK: - SwiftUI

struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStack {
        VStack {
          Section {
            MapView(store: store)
              .frame(height: 225)
          }
          List {
            Section("Search Results") {
              ForEachStore(store.scope(
                state: \.watersources,
                action: AppReducer.Action.watersources
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
            Button(action: { viewStore.send(.setDestination(.readme(.init()))) }) {
              Image(systemName: "info.circle.fill")
            }
          }
          .sheet(
            isPresented: viewStore.binding(
              get: { CasePath.extract(/AppReducer.State.Destination.readme)(from: $0.destination) != nil },
              send: { AppReducer.Action.setDestination($0 ? .readme(.init()) : nil) }
            ),
            content: {
              IfLetStore(store
                .scope(state: \.destination, action: AppReducer.Action.destination)
                .scope(state: /AppReducer.State.Destination.readme, action: AppReducer.Action.Destination.readme)
              ) { ReadMeView(store: $0) }
            }
          )
        }
      }
    }
  }
}

private struct WatersourceNavigationLink: View {
  let store: StoreOf<AppReducer>
  let childStore: StoreOf<Watersource>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      WithViewStore(childStore) { childViewStore in
        NavigationLink(
          destination: IfLetStore(store
            .scope(state: \.destination, action: AppReducer.Action.destination)
            .scope(state: /AppReducer.State.Destination.watersourceDetails, action: AppReducer.Action.Destination.watersourceDetails)
          ) { WatersourceDetailsView(store: $0) },
          tag: childViewStore.id,
          selection: viewStore.binding(
            get: { CasePath.extract(/AppReducer.State.Destination.watersourceDetails)(from: $0.destination)?.model.id },
            send: {
              AppReducer.Action.setDestination(viewStore
                .watersources[id: childViewStore.id]
                .flatMap({ AppReducer.State.Destination.watersourceDetails(WatersourceDetails.State(model: $0.model)) })
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


// MARK: - MapView

private struct MapView: View {
  let store: StoreOf<AppReducer>
  
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
              action: { AppReducer.Action.watersources(id: watersource.id, action: $0) }
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

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: Store(
      initialState: AppReducer.State(
        region: .wilmington,
        watersources: [.init(model: .mock)],
        //        destination: .readme(.init())
        destination: .watersourceDetails(.init(model: .mock))
      ),
      reducer: AppReducer()
    ))
  }
}
