// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "flutter_google_street_view",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "flutter-google-street-view", targets: ["flutter_google_street_view"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", "9.2.0"..<"10.0.0"),
    ],
    targets: [
        .target(
            name: "flutter_google_street_view",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
            ]
        )
    ]
)
