// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StonksUI",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "StonksUI",
            targets: ["StonksUI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StonksUI",
            dependencies: []),
        .testTarget(
            name: "StonksUITests",
            dependencies: ["StonksUI"]),
    ]
)
