// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StonksKit",
    platforms: [
        .macOS(.v13), .iOS(.v16),
    ],
    products: [
        .library(
            name: "StonksKit",
            targets: ["StonksKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift", .upToNextMajor(from: "1.9.1")),
    ],
    targets: [
        .target(
            name: "StonksKit",
            dependencies: [
                .product(name: "KamaalNetworker", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalUtils", package: "KamaalSwift"),
            ]
        ),
        .testTarget(
            name: "StonksKitTests",
            dependencies: [
                "StonksKit",
            ]
        ),
    ]
)
