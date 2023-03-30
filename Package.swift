// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "DeclarativeConnectKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DeclarativeConnectKit",
            targets: ["DeclarativeConnectKit"]
        )
    ],
    dependencies: [
        // Dependencies go here.
    ],
    targets: [
        .target(
            name: "DeclarativeConnectKit",
            dependencies: []
        ),
        .testTarget(
            name: "DeclarativeConnectKitTests",
            dependencies: ["DeclarativeConnectKit"]
        )
    ]
)
