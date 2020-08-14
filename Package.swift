// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Minimind2",
    platforms: [
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "Minimind2",
            targets: ["Minimind2"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Minimind2",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "Minimind2Tests",
            dependencies: ["Minimind2"],
            path: "Tests"
        ),
    ]
)
