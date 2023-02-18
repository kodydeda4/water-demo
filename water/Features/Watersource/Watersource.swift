import SwiftUI
import ComposableArchitecture
import MapKit

struct Watersource: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: RemoteDatabaseClient.Watersource.ID { model.id }
    var model: RemoteDatabaseClient.Watersource
    var isComplete: Bool {
      model.percentBoiled == 100 && model.percentDisinfected == 100 && model.percentFiltered == 100
    }
  }
  
  enum Action: Equatable {
    //...
  }
  
  @Dependency(\.remoteDatabase) var remoteDatabase
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        //...
      }
    }
  }
}

// MARK: - SwiftUI

struct WatersourceView: View {
  let store: StoreOf<Watersource>
  
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
        .overlay {
          ZStack {
            Color.green
            Image(systemName: "checkmark")
              .resizable()
              .scaledToFit()
              .padding()
              .padding()
              .foregroundColor(.white)
          }
          .opacity(viewStore.isComplete ? 0.75 : 0)
        }
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

struct WatersourceMapAnnotationView: View {
  let store: StoreOf<Watersource>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      AsyncImage(
        url: viewStore.model.imageURL,
        content: { $0.resizable().scaledToFill() },
        placeholder: { ProgressView() }
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemGroupedBackground))
      .frame(width: 60)
      .overlay {
        ZStack {
          Color.green
          Image(systemName: "checkmark")
            .resizable()
            .scaledToFit()
            .padding()
            .foregroundColor(.white)
        }
        .opacity(viewStore.isComplete ? 0.75 : 0)
      }
      .clipShape(Circle())
      .shadow(radius: 2)
    }
  }
}

// MARK: - SwiftUI Previews

struct WatersourceView_Previews: PreviewProvider {
  private static let store = StoreOf<Watersource>(
    initialState: Watersource.State(
      model: .init(
        id: UUID(),
        title: "Well A",
        imageURL: URL(string: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.totalsoftwater.com%2Fwp-content%2Fuploads%2F2017%2F08%2Fwells-2212974_1280-180x180.jpg&f=1&nofb=1&ipt=c03b5b92cac7fcf82b6d57cdb22d5df0f9d7d319278cb7278a8beeb32e335a6f&ipo=images")!,
        location: CoordinateLocation(
          latitude: Double.random(in: 31..<35),
          longitude: Double.random(in: -79 ..< -76)
        ),
        percentBoiled: 100,
        percentDisinfected: 100,
        percentFiltered: 100
      )
    ),
    reducer: Watersource()
  )
  
  static var previews: some View {
    WithViewStore(store) { viewStore in
      NavigationStack {
        VStack {
          Map(
            coordinateRegion: .constant(CoordinateRegion.wilmington.rawValue),
            showsUserLocation: true,
            annotationItems: [viewStore.model],
            annotationContent: { watersource in
              MapAnnotation(coordinate: watersource.location.rawValue) {
                WatersourceMapAnnotationView(store: store)
              }
            }
          )
          List {
            Section("List View") {
              WatersourceView(store: store)
            }
          }
        }
        .navigationTitle("Preview")
      }
    }
  }
}
