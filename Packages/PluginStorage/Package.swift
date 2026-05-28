// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PluginStorage",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "PluginStorage",
            targets: ["PluginStorage"]
        ),
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PluginStorage",
            dependencies: [
                "CisumUI",
                "MagicKit",
            ],
            resources: [
                .process("Resources/Storage.xcstrings"),
            ]
        ),
        .testTarget(
            name: "PluginStorageTests",
            dependencies: ["PluginStorage"]
        ),
    ]
)
