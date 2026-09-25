// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "device_haptics",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "device-haptics", targets: ["device_haptics"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "device_haptics",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
