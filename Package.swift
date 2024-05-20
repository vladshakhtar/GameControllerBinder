// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameControllerBinder",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "GameControllerBinder",
            targets: ["GameControllerBinder"]),
    ],
    targets: [
        .target(
            name: "GameControllerBinder",
            path: "Sources",
            exclude: [],
            resources: [],
            publicHeadersPath: nil
        ),
        .testTarget(
            name: "GameControllerBinderTests",
            dependencies: ["GameControllerBinder"]),
    ]
)

