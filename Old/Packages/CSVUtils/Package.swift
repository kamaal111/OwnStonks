// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSVUtils",
    products: [
        .library(
            name: "CSVUtils",
            targets: ["CSVUtils"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CSVUtils",
            dependencies: []
        ),
        .testTarget(
            name: "CSVUtilsTests",
            dependencies: ["CSVUtils"]
        ),
    ]
)
