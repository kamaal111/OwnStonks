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
            targets: ["Models"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/ShrimpExtensions.git", "3.0.0" ..< "4.0.0"),
        .package(path: "../OSLocales")
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                "OSLocales",
                "ShrimpExtensions",
            ]),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]),
    ]
)
