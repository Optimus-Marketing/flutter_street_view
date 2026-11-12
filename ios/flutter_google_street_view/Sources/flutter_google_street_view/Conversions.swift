import GoogleMaps

extension Dictionary where Key == String, Value == Any {
  func bool(_ key: String) -> Bool? { self[key] as? Bool }

  func string(_ key: String) -> String? { self[key] as? String }

  func number(_ key: String) -> NSNumber? { self[key] as? NSNumber }

  func coordinate(_ key: String) -> CLLocationCoordinate2D? {
    guard let values = self[key] as? [NSNumber], values.count == 2 else { return nil }
    return CLLocationCoordinate2D(latitude: values[0].doubleValue, longitude: values[1].doubleValue)
  }

  var hasCamera: Bool {
    ["bearing", "tilt", "zoom", "fov"].contains { self[$0] != nil }
  }

  var orientation: GMSOrientation {
    GMSOrientation(heading: number("bearing")?.doubleValue ?? 0, pitch: number("tilt")?.doubleValue ?? 0)
  }

  var point: CGPoint {
    CGPoint(x: number("x")?.doubleValue ?? 0, y: number("y")?.doubleValue ?? 0)
  }

  var panoramaSource: GMSPanoramaSource {
    string("source") == "outdoor" ? .outside : .default
  }
}

extension GMSPanoramaCamera {
  var json: [String: Any] {
    ["bearing": orientation.heading, "tilt": orientation.pitch, "zoom": zoom, "fov": fov]
  }
}

extension GMSOrientation {
  var json: [String: Any] {
    ["bearing": heading, "tilt": pitch]
  }
}

extension CGPoint {
  var json: [String: Any] {
    ["x": Int(x), "y": Int(y)]
  }
}

extension GMSPanorama {
  var json: [String: Any] {
    [
      "panoId": panoramaID,
      "position": [coordinate.latitude, coordinate.longitude],
      "links": links.map { [$0.panoramaID, $0.heading] },
    ]
  }
}
