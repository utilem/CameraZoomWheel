// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CameraZoomWheel",
    platforms: [
        .iOS(.v17), .macOS(.v15)
    ],
    products: [
        .library(
            name: "CameraZoomWheel",
            targets: ["CameraZoomWheel"]
        ),
    ],
    targets: [
        .target(
            name: "CameraZoomWheel"
        ),
    ],
    swiftLanguageModes: [.v6]
)
