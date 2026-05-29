// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MagicPlayMan",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MagicPlayMan",
            targets: ["MagicPlayMan"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "MagicPlayMan",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
            ]
        )
    ]
)
