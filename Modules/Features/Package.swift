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
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(url: "https://github.com/kamaal111/ForexKit.git", .upToNextMajor(from: "3.1.0")),
        .package(path: "../AppUI"),
        .package(path: "../PersistentData"),
    ],
    targets: [
        .target(
            name: "Transactions",
            dependencies: [
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "KamaalPopUp", package: "KamaalSwift"),
                "ForexKit",
                "AppUI",
                "PersistentData",
            ],
            resources: [
                .process("Internals/Resources"),
            ]
        ),
        .testTarget(
            name: "TransactionsTests",
            dependencies: [
                "Quick",
                "Nimble",
                "Transactions",
                "PersistentData",
            ],
            resources: [
                .process("../../Sources/Transactions/Internals/Resources"),
            ]
        ),
    ]
)
