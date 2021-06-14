// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StonksNetworker",
    products: [
        .library(
            name: "StonksNetworker",
            targets: ["StonksNetworker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StonksNetworker",
            dependencies: []),
        .testTarget(
            name: "StonksNetworkerTests",
            dependencies: ["StonksNetworker"]),
    ]
)
