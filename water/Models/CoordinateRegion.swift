// Copyright © 2023 Deda Inc. All rights reserved.

import MapKit

struct CoordinateRegion {
  var location = CoordinateLocation()
  var span = CoordinateSpan()
}

struct CoordinateLocation {
  var latitude: CLLocationDegrees = 0
  var longitude: CLLocationDegrees = 0
}

struct CoordinateSpan {
  var latitudeDelta: CLLocationDegrees = 0
  var longitudeDelta: CLLocationDegrees = 0
}


// MARK: - Extensions

// CoordinateRegion
extension CoordinateRegion: Codable, Equatable, Hashable {
  init(rawValue: MKCoordinateRegion) {
    self.init(
      location: .init(rawValue: rawValue.center),
      span: .init(rawValue: rawValue.span)
    )
  }

  var rawValue: MKCoordinateRegion {
    .init(
      center: location.rawValue,
      span: span.rawValue
    )
  }
}

// CoordinateLocation
extension CoordinateLocation: Identifiable, Codable, Equatable, Hashable {
  var id: Double {
    longitude * latitude
  }

  init(rawValue: CLLocationCoordinate2D) {
    self.init(
      latitude: rawValue.latitude,
      longitude: rawValue.longitude
    )
  }

  var rawValue: CLLocationCoordinate2D {
    .init(
      latitude: latitude,
      longitude: longitude
    )
  }

  private enum CodingKeys: String, CodingKey {
    case latitude = "lat"
    case longitude = "lon"
  }
}


// CoordinateSpan
extension CoordinateSpan: Codable, Equatable, Hashable {
  init(rawValue: MKCoordinateSpan) {
    self.init(
      latitudeDelta: rawValue.latitudeDelta,
      longitudeDelta: rawValue.longitudeDelta
    )
  }

  var rawValue: MKCoordinateSpan {
    .init(
      latitudeDelta: latitudeDelta,
      longitudeDelta: longitudeDelta
    )
  }
}


// MARK: - CoordinateRegion++

extension CoordinateRegion {
  static let wilmington = Self(
    location: .init(latitude: 34.125727, longitude: -77.874710),
    span: .init(latitudeDelta: 8, longitudeDelta: 8)
  )
}
