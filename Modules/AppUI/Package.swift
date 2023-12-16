// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppUI",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "AppUI", targets: ["AppUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/ForexKit.git", .upToNextMajor(from: "3.2.1")),
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(path: "../SharedStuff"),
    ],
    targets: [
        .target(
            name: "AppUI",
            dependencies: [
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "SharedModels", package: "SharedStuff"),
                "ForexKit",
            ],
            resources: [
                .process("Internals/Resources"),
            ]
        ),
        .testTarget(name: "AppUITests", dependencies: ["AppUI"]),
    ]
)
