// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZaWarudo",
    products: [
        .library(
            name: "ZaWarudo",
            targets: ["ZaWarudo"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZaWarudo",
            dependencies: []
        ),
        .testTarget(
            name: "ZaWarudoTests",
            dependencies: ["ZaWarudo"]
        ),
    ]
)
