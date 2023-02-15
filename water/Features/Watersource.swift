import SwiftUI
import ComposableArchitecture
import MapKit

struct Watersource: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: RemoteDatabaseClient.Watersource.ID { model.id }
    var model: RemoteDatabaseClient.Watersource
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
              title: "\(viewStore.model.boil.description)",
              systemImage: "cross.vial",
              color: .red
            )
            PillView(
              title: "\(viewStore.model.disinfect.description)",
              systemImage: "cross.vial",
              color: .orange
            )
            PillView(
              title: "\(viewStore.model.filter.description)",
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
      NavigationLink(
        destination: {
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

struct WatersourceView_Previews: PreviewProvider {
  private static let store = StoreOf<Watersource>(
    initialState: Watersource.State(model: .mock),
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
              WatersourceView(store: .init(
                initialState: Watersource.State(
                  model: .mock
                ),
                reducer: Watersource()
              ))
            }
          }
        }
        .navigationTitle("Preview")
      }
    }
  }
}
