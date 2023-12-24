// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteNotifcations",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "RemoteNotifcations",
            targets: ["RemoteNotifcations"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(path: "../SharedStuff"),
    ],
    targets: [
        .target(
            name: "RemoteNotifcations",
            dependencies: [
                .product(name: "KamaalCloud", package: "KamaalSwift"),
                .product(name: "KamaalLogger", package: "KamaalSwift"),
                .product(name: "SharedUtils", package: "SharedStuff"),
            ]
        ),
        .testTarget(
            name: "RemoteNotifcationsTests",
            dependencies: ["RemoteNotifcations"]
        ),
    ]
)
