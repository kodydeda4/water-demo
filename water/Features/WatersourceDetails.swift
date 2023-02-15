import SwiftUI
import ComposableArchitecture
import MapKit

struct WatersourceDetails: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: RemoteDatabaseClient.Watersource.ID { model.id }
    var model: RemoteDatabaseClient.Watersource
    
    var isBoilButtonDisabled: Bool { model.boil == 100 }
    var isDisinfectButtonDisabled: Bool { model.disinfect == 100 }
    var isFilterButtonDisabled: Bool { model.filter == 100 }
  }
  
  enum Action: Equatable {
    case boilButtonTapped
    case disinfectButtonTapped
    case filterButtonTapped
    
    case updateRemoteDatabase
    case updateRemoteDatabaseResponse(TaskResult<String>)
  }
  
  @Dependency(\.remoteDatabase) var remoteDatabase
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        
      case .boilButtonTapped:
        state.model.boil = 100
        return .init(value: .updateRemoteDatabase)
        
      case .disinfectButtonTapped:
        state.model.disinfect = 100
        return .init(value: .updateRemoteDatabase)
        
      case .filterButtonTapped:
        state.model.filter = 100
        return .init(value: .updateRemoteDatabase)
        
      case .updateRemoteDatabase:
        return .task { [model = state.model] in
          await .updateRemoteDatabaseResponse(TaskResult {
            try await remoteDatabase.updateWatersource(model)
            return "Success"
          })
        }
        
      case .updateRemoteDatabaseResponse:
        return .none
      }
    }
  }
}

// MARK: - SwiftUI

struct WatersourceDetailsView: View {
  let store: StoreOf<WatersourceDetails>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        Section {
//          WatersourceDetails(store: store)
        }
        Section {
          Button("Boil") {
            viewStore.send(.boilButtonTapped)
          }
          .disabled(viewStore.isBoilButtonDisabled)
          
          Button("Disinfect") {
            viewStore.send(.disinfectButtonTapped)
          }
          .disabled(viewStore.isDisinfectButtonDisabled)
          
          Button("Filter") {
            viewStore.send(.filterButtonTapped)
          }
          .disabled(viewStore.isFilterButtonDisabled)
        }
        
      }
      .navigationTitle(viewStore.model.title)
    }
  }
  
  private struct PillView: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
      HStack {
        Image(systemName: systemImage)
        Text("\(title)")
      }
      .foregroundColor(color)
      .padding(4)
      .frame(maxWidth: .infinity, alignment: .center)
      .background(color.gradient.opacity(0.25))
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
  }
}

// MARK: - SwiftUI Previews

struct WatersourceDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WatersourceDetailsView(store: .init(
        initialState: WatersourceDetails.State(
          model: .init(
            id: UUID(),
            title: "Well A",
            imageURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.totalsoftwater.com%2Fwp-content%2Fuploads%2F2017%2F08%2Fwells-2212974_1280-180x180.jpg&f=1&nofb=1&ipt=c03b5b92cac7fcf82b6d57cdb22d5df0f9d7d319278cb7278a8beeb32e335a6f&ipo=images")!,
            location: CoordinateLocation(
              latitude: Double.random(in: 31..<35),
              longitude: Double.random(in: -79 ..< -76)
            ),
            boil: 59,
            disinfect: 12,
            filter: 42
          )),
        reducer: WatersourceDetails()
      ))
    }
  }
}
