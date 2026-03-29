// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "DB",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "DB",
            targets: ["DB"])
    ],
    dependencies: [
        .package(name: "GRDB", url: "https://github.com/jerimiah797/GRDB.swift.git", .revision("ac47213b0")),
        .package(path: "Mastodon"),
        .package(path: "Secrets"),
        .package(path: "Keychain")
    ],
    targets: [
        .target(
            name: "DB",
            dependencies: ["GRDB", "Mastodon", "Secrets"]),
        .testTarget(
            name: "DBTests",
            dependencies: ["DB", .product(name: "MockKeychain", package: "Keychain")])
    ]
)
