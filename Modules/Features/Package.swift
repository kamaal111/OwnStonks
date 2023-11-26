// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "Transactions", targets: ["Transactions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.2.0")),
        .package(path: "../AppUI"),
    ],
    targets: [
        .target(
            name: "Transactions",
            dependencies: [
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "AppUI", package: "AppUI"),
            ],
            resources: [
                .process("Internals/Resources"),
            ]
        ),
        .testTarget(name: "TransactionsTests", dependencies: [
            "Quick",
            "Nimble",
            "Transactions",
        ]),
    ]
)
