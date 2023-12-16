// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedStuff",
    products: [
        .library(
            name: "SharedStuff",
            targets: ["SharedStuff"]
        ),
    ],
    targets: [
        .target(
            name: "SharedStuff"
        ),
        .testTarget(
            name: "SharedStuffTests",
            dependencies: ["SharedStuff"]
        ),
    ]
)
