// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "Navigation",
            targets: ["Navigation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.6.0")),
        .package(path: "../Features"),
    ],
    targets: [
        .target(
            name: "Navigation",
            dependencies: [
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "KamaalPopUp", package: "KamaalSwift"),
                .product(name: "KamaalNavigation", package: "KamaalSwift"),
                .product(name: "UserSettings", package: "Features"),
                .product(name: "Transactions", package: "Features"),
                .product(name: "Playground", package: "Features"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "NavigationTests",
            dependencies: ["Navigation"]
        ),
    ]
)
