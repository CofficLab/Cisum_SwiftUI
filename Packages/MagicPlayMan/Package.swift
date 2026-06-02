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
        .package(path: "../CisumUI"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MagicPlayMan",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicAlert", package: "MagicAlert"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "MagicPlayManTests",
            dependencies: ["MagicPlayMan"],
            path: "Tests"
        )
    ]
)
