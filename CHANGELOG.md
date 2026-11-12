## 4.1.0

* `iOS`: add Swift Package Manager support, keeping CocoaPods support.
* Require Flutter `3.41.0` and Dart `3.11.0` or newer.

## 4.0.0

* **Breaking**: remove the Web-only options, methods and types (`ControlPosition`, `CloseClickListener` and the `Web only` setters of `StreetViewController`).
* **Breaking**: stop exporting the internal platform interface, method channel, events and option types.
* **Breaking**: `StreetViewPanoramaLink`, `StreetViewPanoramaLocation` and `StreetViewPanoramaOrientation` fields are non-nullable, `orientationToPoint` and `pointToOrientation` return `null` when the platform has no result, click callbacks receive `Point<int>`, `StreetViewSource` is an enum and `Marker.copyWith` uses the field names.
* Free the native view, channel and lifecycle observer when the widget is disposed, and keep the reusable Android panoramas per activity.
* Send camera, panorama and click events only when the widget has a listener for them.
* Apply option changes made before the native view is ready, and keep the controller gesture flags in sync with the widget.
* Fix duplicate replies on iOS when a panorama is reused, markers left on reused iOS panoramas and street names hidden after reuse.
* Fix a crash on Android when the requested location has no panorama.
* Keep the current camera values that `animateTo` does not set on Android.
* `Android`: rewrite in idiomatic Kotlin with the Kotlin DSL, AGP `9.1.0`, Kotlin `2.4.0` and play-services-maps `20.0.0`.
* `iOS`: rewrite in Swift without Objective-C.

## 3.2.0

* Drop `Web` support.
* Merge `street_view_platform_interface` into this package, now at the repo root.
* `Android`:
    - upgrade Android Gradle Plugin to `8.13.1` and Kotlin to `2.2.21`, compile with Java `17`.
    - upgrade com.google.android.gms:play-services-maps to `19.2.0`.
    - set android SDK min version to `24`, compile version to the one of Flutter.
* `iOS`, set min version to `15.0`.
* Fix a null check error when the widget is disposed before the native view is created.

## 3.1.4

* `Android`:
    - fix issue [#17](https://github.com/zyzdev/flutter_street_view/issues/17).
    - upgrade com.google.android.gms:play-services-maps to `18.1.0`.
    - set android SDK min version to `19`, compile version to `33`.


## 3.1.3

* `Web`, fix issue [#23](https://github.com/zyzdev/flutter_street_view/issues/23).

## 3.1.2

* `Web`, fix issue [#21](https://github.com/zyzdev/flutter_street_view/issues/21).

## 3.1.1

* `Android`, upgrade Kotlin gradle plugin version to `1.6.10`.

## 3.1.0

* Add feature, call API `FlutterGoogleStreetView.createdCount` to get created count of native street view.
* bugs fix

## 3.0.1

* Add example `Street View In ListView Demo`.
* bugs fix

## 3.0.0

* `Android` & `iOS`, reuse StreetViewPanorama to reduce instantiation count for saving billing([android](https://developers.google.com/maps/documentation/android-sdk/usage-and-billing#dynamic-street-view), [iOS](https://developers.google.com/maps/documentation/ios-sdk/usage-and-billing#dynamic-street-view))

## 2.2.8

* Migrate to flutter 3.0.0

## 2.2.7

* bugs fix

## 2.2.6

* bugs fix

## 2.2.5

* bugs fix

## 2.2.4

* Upgrade street_view_platform_interface to v1.0.5

## 2.2.3

* bugs fix

## 2.2.2

* Modify description.

## 2.2.1

* bugs fix.

## 2.2.0

* `iOS`. Add feature `putting marker to street view`, iOS only.
* `example`. Add demo of feature `putting marker to street view` to `Street View Panorama init(demo/street_view_panorama_init.dart)`.

## 2.1.0

* `Web`. reuse StreetViewPanorama to reduce instantiation count for saving [billing](https://developers.google.com/maps/documentation/javascript/usage-and-billing#dynamic-street-view).

## 2.0.1

* fine tune API ref more clear.

## 2.0.0

* Add Web support.
* bugs fix.

## 1.0.2

* fix bug that onPanoramaChangeListener doesn't response on Android side, if setPosition can't find a valid panorama.

## 1.0.1

* Remove `Android only`. in README

## 1.0.0

* Add iOS support.

## 0.1.2

* fix bugs that FlutterGoogleStreetView assert logic of param `initPanoId` & `initPanoId` is wrong.
* migrate example to null-safety.

## 0.1.1

* Trying to remove IOS support info tag

## 0.1.0

* Migrating to null safety.

## 0.0.7

* Remove iOS user guide.

## 0.0.6

* Modify plugin description.

## 0.0.5

* fix typo in README.md
* fine tune code of Sample Usage in README.md  

## 0.0.4

* Same as version 0.0.3, just fix typo. 
* Android, remove flutter.jar dependency to avoid build fail.

## 0.0.3

* droid, remove flutter.jar dependency to avoid build fail.

## 0.0.2

* Remove google map API key

## 0.0.1

* Initial developers preview release.
* Android only. 

