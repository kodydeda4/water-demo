import SwiftUI
import ComposableArchitecture
import MapKit

struct SearchResult: ReducerProtocol {
  struct State: Equatable, Identifiable {
    let id: UUID
    let title: String
    let imageURL: URL
    let location: CoordinateLocation
    var boil: Double
    var disinfect: Double
    var filter: Double
    
    var isBoilButtonDisabled: Bool { boil == 100 }
    var isDisinfectButtonDisabled: Bool { disinfect == 100 }
    var isFilterButtonDisabled: Bool { filter == 100 }
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
        state.boil = 100
        return .init(value: .updateRemoteDatabase)
        
      case .disinfectButtonTapped:
        state.disinfect = 100
        return .init(value: .updateRemoteDatabase)
        
      case .filterButtonTapped:
        state.filter = 100
        return .init(value: .updateRemoteDatabase)
        
      case .updateRemoteDatabase:
        return .task { [state = state] in
          await .updateRemoteDatabaseResponse(TaskResult {
            try await remoteDatabase.updateWatersource(.init(
              id: state.id,
              title: state.title,
              imageURL: state.imageURL,
              location: state.location,
              boil: state.boil,
              disinfect: state.disinfect,
              filter: state.filter
            ))
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

struct SearchResultView: View {
  let store: StoreOf<SearchResult>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      HStack {
        AsyncImage(
          url: viewStore.imageURL,
          content: { $0.resizable().scaledToFill() },
          placeholder: { ProgressView() }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .frame(width: 60)
        .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 2) {
          HStack {
            Text("\(viewStore.title)")
              .fontWeight(.medium)
            Spacer()
            Text("3.4 mi")
              .foregroundStyle(.secondary)
          }
          
          Text("\(viewStore.id.description)")
            .lineLimit(1)
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
          
          HStack {
            PillView(
              title: "\(viewStore.boil.description)",
              systemImage: "cross.vial",
              color: .red
            )
            PillView(
              title: "\(viewStore.disinfect.description)",
              systemImage: "cross.vial",
              color: .orange
            )
            PillView(
              title: "\(viewStore.filter.description)",
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

struct SearchResultDetailsView: View {
  let store: StoreOf<SearchResult>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        Section {
          SearchResultView(store: store)
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
      .navigationTitle(viewStore.title)
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

struct SearchResultView_Previews: PreviewProvider {
  static var previews: some View {
    SearchResultView(store: .init(
      initialState: SearchResult.State(
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
      ),
      reducer: SearchResult()
    ))
  }
}
struct SearchResultDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SearchResultDetailsView(store: .init(
        initialState: SearchResult.State(
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
        ),
        reducer: SearchResult()
      ))
    }
  }
}
