// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PersistentData",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "PersistentData",
            targets: ["PersistentData"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(url: "https://github.com/kamaal111/ForexKit.git", .upToNextMajor(from: "3.1.0")),
    ],
    targets: [
        .target(
            name: "PersistentData",
            dependencies: [
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                "ForexKit",
            ]
        ),
        .testTarget(
            name: "PersistentDataTests",
            dependencies: [
                "PersistentData",
            ]
        ),
    ]
)
