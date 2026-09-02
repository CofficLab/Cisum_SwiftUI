// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PluginStorage",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PluginStorage",
            targets: ["PluginStorage"]
        ),
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../CisumKernel"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PluginStorage",
            dependencies: [
                "CisumUI",
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "MagicKit", package: "MagicKit"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "StoragePluginTests",
            dependencies: ["PluginStorage"],
            path: "Tests"
        ),
    ]
)
