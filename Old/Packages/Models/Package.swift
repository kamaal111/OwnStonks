// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/ShrimpExtensions.git", "3.1.0" ..< "4.0.0"),
        .package(path: "../OSLocales"),
        .package(path: "../CSVUtils"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                "CSVUtils",
                "OSLocales",
                "ShrimpExtensions",
            ]
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]
        ),
    ]
)
