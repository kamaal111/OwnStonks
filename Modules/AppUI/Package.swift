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
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
    ],
    targets: [
        .target(
            name: "AppUI",
            dependencies: [
                .product(name: "KamaalUI", package: "KamaalSwift"),
            ],
            resources: [
                .process("Internals/Resources"),
            ]
        ),
        .testTarget(name: "AppUITests", dependencies: ["AppUI"]),
    ]
)
