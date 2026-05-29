// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBook",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBook",
            targets: ["PluginBook"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../MagicKit")
    ],
    targets: [
        .target(
            name: "PluginBook",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginBook",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookTests",
            dependencies: ["PluginBook"],
            path: "Tests/PluginBookTests"
        )
    ]
)
