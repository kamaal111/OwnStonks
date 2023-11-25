// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppUI",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "AppUI", targets: ["AppUI"]),
    ],
    targets: [
        .target(name: "AppUI"),
        .testTarget(name: "AppUITests", dependencies: ["AppUI"]),
    ]
)
