// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-stonks-api",
    platforms: [
        .macOS(.v13), .iOS(.v16),
    ],
    products: [
        .library(
            name: "StonksAPI",
            targets: ["StonksAPI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.6.1")),
    ],
    targets: [
        .target(
            name: "StonksAPI",
            dependencies: [
                .product(name: "KamaalNetworker", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalUtils", package: "KamaalSwift"),
            ]
        ),
        .testTarget(
            name: "SwiftStonksAPITests",
            dependencies: ["StonksAPI"]
        ),
    ]
)
