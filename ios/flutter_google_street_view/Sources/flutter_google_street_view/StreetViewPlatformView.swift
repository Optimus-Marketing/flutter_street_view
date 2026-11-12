import Flutter
import GoogleMaps
import UIKit

final class StreetViewPlatformView: NSObject, FlutterPlatformView {
  private let panoramaView: GMSPanoramaView
  private let isReusedView: Bool
  private let pool: StreetViewPool
  private let methodChannel: FlutterMethodChannel
  private let markersController: MarkersController
  private let longPressRecognizer = UILongPressGestureRecognizer()
  private var pendingReadyResult: FlutterResult?
  private var isReady = false
  private var noPanoramaMessage = "No panorama found"
  private var sendsCameraChanges = false
  private var sendsPanoramaChanges = false
  private var sendsPanoramaClicks = false
  private var sendsPanoramaLongClicks = false

  init(
    viewId: Int64,
    creationParams: [String: Any],
    registrar: FlutterPluginRegistrar,
    pool: StreetViewPool
  ) {
    let idleView = pool.reuse()
    isReusedView = idleView != nil
    panoramaView = idleView ?? pool.create()
    self.pool = pool
    methodChannel = FlutterMethodChannel(
      name: "flutter_google_street_view_\(viewId)",
      binaryMessenger: registrar.messenger()
    )
    markersController = MarkersController(panoramaView: panoramaView, registrar: registrar)
    super.init()

    methodChannel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    panoramaView.delegate = self
    longPressRecognizer.addTarget(self, action: #selector(onLongPress(_:)))
    panoramaView.addGestureRecognizer(longPressRecognizer)
    applyOptions(creationParams)
    markersController.add(creationParams["markersToAdd"] as? [[String: Any]] ?? [])
    if isReusedView {
      panoramaView.alpha = 1
      markReady()
    }
  }

  deinit {
    methodChannel.setMethodCallHandler(nil)
    pendingReadyResult?(nil)
    recyclePanoramaView()
  }

  func view() -> UIView {
    panoramaView
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "streetView#waitForStreetView":
      if isReady {
        result(readyState)
      } else {
        pendingReadyResult = result
      }
    case "streetView#updateOptions":
      applyOptions(arguments)
      result(nil)
    case "streetView#animateTo":
      let durationInSeconds = (arguments.number("duration")?.doubleValue ?? 0) / 1000
      panoramaView.animate(to: camera(with: arguments), animationDuration: durationInSeconds)
      result(nil)
    case "streetView#getLocation":
      result(panoramaView.panorama?.json)
    case "streetView#getPanoramaCamera":
      result(panoramaView.camera.json)
    case "streetView#orientationToPoint":
      result(panoramaView.point(for: arguments.orientation).json)
    case "streetView#pointToOrientation":
      result(panoramaView.orientation(for: arguments.point).json)
    case "markers#update":
      markersController.update(arguments)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private var readyState: [String: Any] {
    [
      "panningGesturesEnabled": panoramaView.orientationGestures,
      "streetNamesEnabled": !panoramaView.streetNamesHidden,
      "userNavigationEnabled": panoramaView.navigationGestures,
      "zoomGesturesEnabled": panoramaView.zoomGestures,
      "streetViewCount": pool.viewCount,
    ]
  }

  private func markReady() {
    guard !isReady else { return }
    isReady = true
    pendingReadyResult?(readyState)
    pendingReadyResult = nil
  }

  private func applyOptions(_ options: [String: Any]) {
    rememberListeners(options)
    if let enabled = options.bool("panningGesturesEnabled") {
      panoramaView.orientationGestures = enabled
    }
    if let enabled = options.bool("streetNamesEnabled") {
      panoramaView.streetNamesHidden = !enabled
    }
    if let enabled = options.bool("userNavigationEnabled") {
      panoramaView.navigationGestures = enabled
    }
    if let enabled = options.bool("zoomGesturesEnabled") {
      panoramaView.zoomGestures = enabled
    }
    move(with: options)
    if options.hasCamera {
      panoramaView.camera = camera(with: options)
    }
  }

  private func move(with options: [String: Any]) {
    if let panoId = options.string("panoId") {
      noPanoramaMessage = "No panorama found with id \(panoId)"
      panoramaView.move(toPanoramaID: panoId)
    } else if let position = options.coordinate("position") {
      noPanoramaMessage = "No panorama found near \(position.latitude), \(position.longitude)"
      if let radius = options.number("radius")?.uintValue {
        panoramaView.moveNearCoordinate(position, radius: radius, source: options.panoramaSource)
      } else {
        panoramaView.moveNearCoordinate(position, source: options.panoramaSource)
      }
    }
  }

  private func camera(with options: [String: Any]) -> GMSPanoramaCamera {
    let current = panoramaView.camera
    let orientation = GMSOrientation(
      heading: options.number("bearing")?.doubleValue ?? current.orientation.heading,
      pitch: options.number("tilt")?.doubleValue ?? current.orientation.pitch
    )
    return GMSPanoramaCamera(
      orientation: orientation,
      zoom: options.number("zoom")?.floatValue ?? current.zoom,
      fov: options.number("fov")?.doubleValue ?? current.fov
    )
  }

  private func rememberListeners(_ options: [String: Any]) {
    sendsCameraChanges = options.bool("hasCameraChangeListener") ?? sendsCameraChanges
    sendsPanoramaChanges = options.bool("hasPanoramaChangeListener") ?? sendsPanoramaChanges
    sendsPanoramaClicks = options.bool("hasPanoramaClickListener") ?? sendsPanoramaClicks
    sendsPanoramaLongClicks = options.bool("hasPanoramaLongClickListener") ?? sendsPanoramaLongClicks
  }

  private func clickArguments(at point: CGPoint) -> [String: Any] {
    panoramaView.orientation(for: point).json.merging(point.json) { current, _ in current }
  }

  private func sendPanoramaChange(_ arguments: [String: Any]) {
    markReady()
    guard sendsPanoramaChanges else { return }
    methodChannel.invokeMethod("pano#onChange", arguments: arguments)
  }

  private func recyclePanoramaView() {
    panoramaView.delegate = nil
    panoramaView.removeGestureRecognizer(longPressRecognizer)
    markersController.removeAll()
    panoramaView.alpha = 0
    panoramaView.orientationGestures = true
    panoramaView.streetNamesHidden = false
    panoramaView.navigationGestures = true
    panoramaView.zoomGestures = true
    panoramaView.camera = GMSPanoramaCamera(orientation: GMSOrientation(heading: 0, pitch: 0), zoom: 1, fov: 90)
    panoramaView.removeFromSuperview()
    pool.recycle(panoramaView)
  }

  @objc private func onLongPress(_ recognizer: UILongPressGestureRecognizer) {
    guard recognizer.state == .began, sendsPanoramaLongClicks else { return }
    let arguments = clickArguments(at: recognizer.location(in: panoramaView))
    methodChannel.invokeMethod("pano#onLongClick", arguments: arguments)
  }
}

extension StreetViewPlatformView: GMSPanoramaViewDelegate {
  func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama?) {
    sendPanoramaChange(panorama?.json ?? ["error": noPanoramaMessage])
  }

  func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
    sendPanoramaChange(["error": noPanoramaMessage])
  }

  func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveToPanoramaID panoramaID: String) {
    sendPanoramaChange(["error": noPanoramaMessage])
  }

  func panoramaViewDidFinishRendering(_ panoramaView: GMSPanoramaView) {
    markReady()
  }

  func panoramaView(_ panoramaView: GMSPanoramaView, didMove camera: GMSPanoramaCamera) {
    guard sendsCameraChanges else { return }
    methodChannel.invokeMethod("camera#onChange", arguments: camera.json)
  }

  func panoramaView(_ panoramaView: GMSPanoramaView, didTap point: CGPoint) {
    guard sendsPanoramaClicks else { return }
    methodChannel.invokeMethod("pano#onClick", arguments: clickArguments(at: point))
  }

  func panoramaView(_ panoramaView: GMSPanoramaView, didTap marker: GMSMarker) -> Bool {
    if let markerId = marker.userData as? String {
      methodChannel.invokeMethod("marker#onTap", arguments: ["markerId": markerId])
    }
    return false
  }
}
