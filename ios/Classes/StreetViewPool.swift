import GoogleMaps

final class StreetViewPool {
  private var idleViews: [GMSPanoramaView] = []
  private(set) var viewCount = 0

  func reuse() -> GMSPanoramaView? {
    idleViews.popLast()
  }

  func create() -> GMSPanoramaView {
    viewCount += 1
    return GMSPanoramaView(frame: .zero)
  }

  func recycle(_ view: GMSPanoramaView) {
    idleViews.append(view)
  }
}
