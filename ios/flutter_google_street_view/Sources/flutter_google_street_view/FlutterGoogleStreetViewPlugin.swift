import Flutter
import UIKit

public final class FlutterGoogleStreetViewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(StreetViewFactory(registrar: registrar), withId: "flutter_google_street_view")
  }
}
