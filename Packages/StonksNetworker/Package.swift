// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StonksNetworker",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "StonksNetworker",
            targets: ["StonksNetworker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/ShrimpExtensions.git", from: "2.0.0"),
        .package(url: "https://github.com/kamaal111/XiphiasNet.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "StonksNetworker",
            dependencies: [
                "ShrimpExtensions",
                "XiphiasNet"
            ]),
        .testTarget(
            name: "StonksNetworkerTests",
            dependencies: ["StonksNetworker"]),
    ]
)
