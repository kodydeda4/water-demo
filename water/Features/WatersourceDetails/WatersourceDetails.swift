import SwiftUI
import ComposableArchitecture
import MapKit

struct WatersourceDetails: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: RemoteDatabaseClient.Watersource.ID { model.id }
    var model: RemoteDatabaseClient.Watersource
    var isBoilingComplete: Bool { model.percentBoiled == 100 }
    var isDisinfectingComplete: Bool { model.percentDisinfected == 100 }
    var isFilteringComplete: Bool { model.percentFiltered == 100 }
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
        state.model.percentBoiled = 100
        return .init(value: .updateRemoteDatabase)
        
      case .disinfectButtonTapped:
        state.model.percentDisinfected = 100
        return .init(value: .updateRemoteDatabase)
        
      case .filterButtonTapped:
        state.model.percentFiltered = 100
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
          Header(store: store)
        }
        Section(
          header: Text("Step 1. Boil"),
          footer: Text("Boiling is the surest method to kill disease-causing germs, including viruses, bacteria, and parasites.")
        ) {
          Button(viewStore.isBoilingComplete ? "Complete" : "Start Boiling") {
            viewStore.send(.boilButtonTapped)
          }
          .disabled(viewStore.isBoilingComplete)
        }
        Section(
          header: Text("Step 2. Disinfect"),
          footer: Text("Make small quantities of water safer to drink by using a chemical disinfectant.")
        ) {
          Button(viewStore.isDisinfectingComplete ? "Complete" : "Start Disinfecting") {
            viewStore.send(.disinfectButtonTapped)
          }
          .disabled(viewStore.isDisinfectingComplete)
        }
        Section(
          header: Text("Step 3. Filter"),
          footer: Text("Remove disease-causing parasites such as Cryptosporidium and Giardia.")
        ) {
          Button(viewStore.isFilteringComplete ? "Complete" : "Start Filtering") {
            viewStore.send(.filterButtonTapped)
          }
          .disabled(viewStore.isFilteringComplete)
        }
      }
      .navigationTitle(viewStore.model.title)
    }
  }
}

private struct Header: View {
  let store: StoreOf<WatersourceDetails>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        AsyncImage(
          url: viewStore.model.imageURL,
          content: { $0.resizable().scaledToFill() },
          placeholder: { ProgressView() }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .frame(width: 60)
        .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 2) {
          HStack {
            Text("\(viewStore.model.title)")
              .fontWeight(.medium)
            Spacer()
            Text("3.4 mi")
              .foregroundStyle(.secondary)
          }
          
          Text("\(viewStore.model.id.description)")
            .lineLimit(1)
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
          
          HStack {
            PillView(
              title: "\(viewStore.model.percentBoiled.description)",
              systemImage: "cross.vial",
              color: .red
            )
            PillView(
              title: "\(viewStore.model.percentDisinfected.description)",
              systemImage: "cross.vial",
              color: .orange
            )
            PillView(
              title: "\(viewStore.model.percentFiltered.description)",
              systemImage: "flame",
              color: .green
            )
          }
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(1)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
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
            percentBoiled: 59,
            percentDisinfected: 12,
            percentFiltered: 42
          )),
        reducer: WatersourceDetails()
      ))
    }
  }
}
