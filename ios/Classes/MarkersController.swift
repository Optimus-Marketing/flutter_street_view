import Flutter
import GoogleMaps

final class MarkersController {
  private let panoramaView: GMSPanoramaView
  private let registrar: FlutterPluginRegistrar
  private var markersById: [String: GMSMarker] = [:]

  init(panoramaView: GMSPanoramaView, registrar: FlutterPluginRegistrar) {
    self.panoramaView = panoramaView
    self.registrar = registrar
  }

  func add(_ markers: [[String: Any]]) {
    for json in markers {
      guard let markerId = json.string("markerId") else { continue }
      let marker = GMSMarker()
      marker.userData = markerId
      apply(json, to: marker)
      markersById[markerId] = marker
    }
  }

  func update(_ updates: [String: Any]) {
    add(updates["markersToAdd"] as? [[String: Any]] ?? [])
    for json in updates["markersToChange"] as? [[String: Any]] ?? [] {
      guard let markerId = json.string("markerId"), let marker = markersById[markerId] else { continue }
      apply(json, to: marker)
    }
    for markerId in updates["markerIdsToRemove"] as? [String] ?? [] {
      markersById.removeValue(forKey: markerId)?.panoramaView = nil
    }
  }

  func removeAll() {
    markersById.values.forEach { $0.panoramaView = nil }
    markersById.removeAll()
  }

  private func apply(_ json: [String: Any], to marker: GMSMarker) {
    if let position = json.coordinate("position") {
      marker.position = position
    }
    if let icon = json["icon"] as? [Any] {
      marker.icon = image(from: icon)
    }
    if let visible = json.bool("visible") {
      marker.panoramaView = visible ? panoramaView : nil
    }
  }

  private func image(from icon: [Any]) -> UIImage? {
    switch icon.first as? String {
    case "defaultMarker":
      let hue = (icon.dropFirst().first as? NSNumber)?.doubleValue ?? 0
      return GMSMarker.markerImage(with: UIColor(hue: hue / 360, saturation: 1, brightness: 0.7, alpha: 1))
    case "fromAssetImage":
      guard icon.count == 3, let assetName = icon[1] as? String else { return nil }
      let image = UIImage(named: registrar.lookupKey(forAsset: assetName))
      return image.flatMap { scaled($0, by: (icon[2] as? NSNumber)?.doubleValue ?? 1) }
    case "fromBytes":
      guard let bytes = icon.dropFirst().first as? FlutterStandardTypedData else { return nil }
      return UIImage(data: bytes.data, scale: UIScreen.main.scale)
    default:
      return nil
    }
  }

  private func scaled(_ image: UIImage, by scale: Double) -> UIImage {
    guard abs(scale - 1) > 1e-3, let cgImage = image.cgImage else { return image }
    return UIImage(cgImage: cgImage, scale: image.scale * scale, orientation: image.imageOrientation)
  }
}
