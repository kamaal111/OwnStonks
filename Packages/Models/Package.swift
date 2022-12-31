// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    products: [
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    dependencies: [
        .package(path: "../OSLocales")
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                "OSLocales",
            ]),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]),
    ]
)
