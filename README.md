# flutter_google_street_view

A Flutter widget that shows Google Street View panoramas on [Android][android] and [iOS][ios].

[android]: https://developers.google.com/maps/documentation/android-sdk/streetview
[ios]: https://developers.google.com/maps/documentation/ios-sdk/streetview

## Installation

```yaml
dependencies:
  flutter_google_street_view:
    git:
      url: https://github.com/Optimus-Marketing/flutter_street_view.git
      ref: v4.0.0
```

Requires Flutter 3.41 or newer, Android API 24 or newer and iOS 15 or newer.

## Getting Started

1. Get an API key at <https://cloud.google.com/maps-platform/>.
2. Enable "Maps SDK for Android" and "Maps SDK for iOS" in the [Google Cloud Console](https://console.cloud.google.com/).

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

### Android

Specify your API key in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

### iOS

Specify your API key in `ios/Runner/AppDelegate.swift`:

```swift
import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR KEY HERE")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```

## Usage

Set exactly one of `initPos` or `initPanoId`:

```dart
FlutterGoogleStreetView(
  initPos: const LatLng(37.769263, -122.450727),
  initSource: StreetViewSource.outdoor,
  initBearing: 30,
  zoomGesturesEnabled: false,
  onStreetViewCreated: (controller) => controller.animateTo(
    camera: const StreetViewPanoramaCamera(bearing: 90, tilt: 30),
    duration: 750,
  ),
)
```

Changing the widget's options in a rebuild updates the native view. The `StreetViewController` received in `onStreetViewCreated` moves the panorama, animates the camera and toggles gestures. Markers are supported on iOS only.

The `example` app shows every option, event and controller method. Specify your API key in it before running it.

## Screenshots

| Android | iOS |
| ------- | --- |
| <img title="Android" src="https://user-images.githubusercontent.com/16483162/145322579-e9f6e838-9b81-480c-a808-5d3ec67de3b6.png" width="300" /> | <img title="iOS" src="https://user-images.githubusercontent.com/16483162/145323552-86f27e40-6334-4e5f-8382-c6b73ceb2ddb.png" width="300" /> |

## Created count

Google bills each panorama instantiation ([Android](https://developers.google.com/maps/documentation/android-sdk/usage-and-billing#dynamic-street-view), [iOS](https://developers.google.com/maps/documentation/ios-sdk/usage-and-billing#dynamic-street-view)). The plugin reuses native panoramas between widgets, and `FlutterGoogleStreetView.createdCount` returns how many it has created.
