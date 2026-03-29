// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "HTTP",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "HTTP",
            targets: ["HTTP"]),
        .library(
            name: "Stubbing",
            targets: ["Stubbing"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HTTP",
            dependencies: []),
        .target(
            name: "Stubbing",
            dependencies: ["HTTP"]),
        .testTarget(
            name: "HTTPTests",
            dependencies: ["HTTP"])
    ]
)
