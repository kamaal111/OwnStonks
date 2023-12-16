// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedStuff",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "SharedUtils", targets: ["SharedUtils"]),
        .library(name: "SharedModels", targets: ["SharedModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/ForexKit.git", .upToNextMajor(from: "3.2.1")),
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
    ],
    targets: [
        .target(name: "SharedUtils"),
        .target(
            name: "SharedModels",
            dependencies: [
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                "ForexKit",
            ]
        ),
    ]
)
