// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StonksLocale",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15), .iOS(.v13),
    ],
    products: [
        .library(
            name: "StonksLocale",
            targets: ["StonksLocale"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StonksLocale",
            dependencies: [],
            resources: [.process("Resources")]),
        .testTarget(
            name: "StonksLocaleTests",
            dependencies: ["StonksLocale"]),
    ]
)
