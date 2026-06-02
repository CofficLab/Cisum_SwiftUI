// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginReset",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginReset",
            targets: ["PluginReset"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "PluginReset",
            dependencies: [
                "CisumUI",
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginReset",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginResetTests",
            dependencies: ["PluginReset"],
            path: "Tests"
        )
    ]
)
