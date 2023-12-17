// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let transactionResourcesPath = "Internals/Resources"
let userSettingsResourcesPath = "Internals/Resources"

let package = Package(
    name: "Features",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "Transactions", targets: ["Transactions"]),
        .library(name: "UserSettings", targets: ["UserSettings"]),
        .library(name: "ValutaConversion", targets: ["ValutaConversion"]),
        .library(name: "Playground", targets: ["Playground"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(url: "https://github.com/kamaal111/ForexKit.git", .upToNextMajor(from: "3.2.1")),
        .package(url: "https://github.com/kamaal111/MockURLProtocol.git", "0.1.1" ..< "0.2.0"),
        .package(path: "../PersistentData"),
        .package(path: "../SharedStuff"),
    ],
    targets: [
        .target(
            name: "Transactions",
            dependencies: [
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "KamaalPopUp", package: "KamaalSwift"),
                .product(name: "SharedModels", package: "SharedStuff"),
                .product(name: "SharedUI", package: "SharedStuff"),
                "ForexKit",
                "PersistentData",
                "ValutaConversion",
                "UserSettings",
            ],
            resources: [
                .process(transactionResourcesPath),
            ]
        ),
        .testTarget(
            name: "TransactionsTests",
            dependencies: [
                .product(name: "SharedModels", package: "SharedStuff"),
                "Quick",
                "Nimble",
                "Transactions",
                "PersistentData",
                "ForexKit",
            ],
            resources: [
                .process("../../Sources/Transactions/\(transactionResourcesPath)"),
            ]
        ),
        .target(
            name: "UserSettings",
            dependencies: [
                .product(name: "KamaalSettings", package: "KamaalSwift"),
                .product(name: "KamaalUtils", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "SharedUtils", package: "SharedStuff"),
                "ForexKit",
            ],
            resources: [
                .process(userSettingsResourcesPath),
            ]
        ),
        .testTarget(
            name: "UserSettingsTests",
            dependencies: [
                "Quick",
                "Nimble",
                "UserSettings",
                "ForexKit",
                .product(name: "KamaalSettings", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
            ],
            resources: [
                .process("../../Sources/UserSettings/\(userSettingsResourcesPath)"),
            ]
        ),
        .target(
            name: "ValutaConversion",
            dependencies: [
                .product(name: "KamaalUtils", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "SharedUtils", package: "SharedStuff"),
                .product(name: "SharedModels", package: "SharedStuff"),
                "ForexKit",
            ],
            resources: [
                .process("Internals/Resources"),
            ]
        ),
        .testTarget(
            name: "ValutaConversionTests",
            dependencies: [
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "SharedModels", package: "SharedStuff"),
                "ValutaConversion",
                "Quick",
                "Nimble",
                "ForexKit",
                "MockURLProtocol",
            ]
        ),
        .target(
            name: "Playground",
            dependencies: [
                .product(name: "KamaalNavigation", package: "KamaalSwift"),
                .product(name: "KamaalUI", package: "KamaalSwift"),
                .product(name: "SharedUI", package: "SharedStuff"),
            ]
        ),
    ]
)
