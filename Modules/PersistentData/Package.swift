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
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.6.0")),
        .package(url: "https://github.com/kamaal111/ForexKit.git", .upToNextMajor(from: "3.2.1")),
        .package(url: "https://github.com/kamaal111/swift-builder.git", .upToNextMinor(from: "0.1.1")),
        .package(path: "../SharedStuff"),
    ],
    targets: [
        .target(
            name: "PersistentData",
            dependencies: [
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalCloud", package: "KamaalSwift"),
                .product(name: "SharedModels", package: "SharedStuff"),
                .product(name: "SharedUtils", package: "SharedStuff"),
                .product(name: "SwiftBuilder", package: "swift-builder"),
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
