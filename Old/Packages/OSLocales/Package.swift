// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OSLocales",
    defaultLocalization: "en",
    products: [
        .library(
            name: "OSLocales",
            targets: ["OSLocales"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OSLocales",
            dependencies: []
        ),
        .testTarget(
            name: "OSLocalesTests",
            dependencies: ["OSLocales"]
        ),
    ]
)
