// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Network", targets: ["Network"]),
        .library(name: "ForexAPI", targets: ["ForexAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/XiphiasNet.git", "7.0.0" ..< "8.0.0"),
        .package(path: "../Models"),
    ],
    targets: [
        .target(name: "Network", dependencies: []),
        .testTarget(name: "NetworkTests", dependencies: ["Network"]),
        .target(name: "ForexAPI", dependencies: ["XiphiasNet", "Models"]),
    ]
)
