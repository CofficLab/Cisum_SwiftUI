// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MagicPlayMan",
    defaultLocalization: "en",
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
        .package(path: "../CisumUIComponents"),
    ],
    targets: [
        .target(
            name: "MagicPlayMan",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "MagicPlayManTests",
            dependencies: ["MagicPlayMan"],
            path: "Tests"
        )
    ]
)
