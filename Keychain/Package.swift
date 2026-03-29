// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Keychain",
            targets: ["Keychain"]),
        .library(
            name: "MockKeychain",
            targets: ["MockKeychain"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Keychain",
            dependencies: []),
        .target(
            name: "MockKeychain",
            dependencies: ["Keychain"]),
        .testTarget(
            name: "KeychainTests",
            dependencies: ["MockKeychain"])
    ]
)
