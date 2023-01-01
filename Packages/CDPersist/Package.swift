// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CDPersist",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "CDPersist",
            targets: ["CDPersist"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/Logster.git", "1.1.0" ..< "2.0.0"),
        .package(url: "https://github.com/kamaal111/ManuallyManagedObject.git", "2.0.2" ..< "3.0.0"),
        .package(path: "../Models"),
        .package(path: "../ZaWarudo"),
    ],
    targets: [
        .target(
            name: "CDPersist",
            dependencies: [
                "Logster",
                "ManuallyManagedObject",
                "Models",
                "ZaWarudo",
            ]),
        .testTarget(
            name: "CDPersistTests",
            dependencies: ["CDPersist"]),
    ]
)
