// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookSettings",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookSettings",
            targets: ["PluginBookSettings"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../MagicKit")
    ],
    targets: [
        .target(
            name: "PluginBookSettings",
            dependencies: [
                "CisumUI",
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginBookSettings",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookSettingsTests",
            dependencies: ["PluginBookSettings"],
            path: "Tests/PluginBookSettingsTests"
        )
    ]
)
