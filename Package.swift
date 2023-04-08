// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ascon-p-swift",
    products: [
        .library(
            name: "AsconP",
            targets: ["AsconP"]),
    ],
    targets: [
        .target(
            name: "AsconP"),
        .testTarget(
            name: "AsconPTests",
            dependencies: ["AsconP"]),
    ]
)
