// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StonksUI",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(
            name: "StonksUI",
            targets: ["StonksUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/SalmonUI.git", from: "4.0.0"),
        .package(path: "../StonksLocale"),
    ],
    targets: [
        .target(
            name: "StonksUI",
            dependencies: [
                "SalmonUI",
                "StonksLocale"
            ]),
        .testTarget(
            name: "StonksUITests",
            dependencies: ["StonksUI"]),
    ]
)
