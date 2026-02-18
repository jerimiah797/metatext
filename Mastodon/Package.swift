// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Mastodon",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Mastodon",
            targets: ["Mastodon"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Mastodon"),
        .testTarget(
            name: "MastodonTests",
            dependencies: ["Mastodon"])
    ]
)
