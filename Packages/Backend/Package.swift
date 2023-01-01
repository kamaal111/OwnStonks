// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Backend",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Backend",
            targets: ["Backend"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject.git", "2.8.3" ..< "3.0.0"),
        .package(url: "https://github.com/Kamaalio/ShrimpExtensions.git", "3.0.0" ..< "4.0.0"),
        .package(path: "../CDPersist"),
        .package(path: "../Models"),
        .package(path: "../ZaWarudo"),
    ],
    targets: [
        .target(
            name: "Backend",
            dependencies: [
                "Swinject",
                "ShrimpExtensions",
                "CDPersist",
                "Models",
                "ZaWarudo",
            ]),
        .testTarget(
            name: "BackendTests",
            dependencies: ["Backend"]),
    ]
)
