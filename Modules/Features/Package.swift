// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "Transactions", targets: ["Transactions"]),
    ],
    targets: [
        .target(name: "Transactions"),
        .testTarget(name: "TransactionsTests", dependencies: ["Transactions"]),
    ]
)
