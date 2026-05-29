// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookControl",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookControl",
            targets: ["PluginBookControl"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../PluginBookScene"),
        .package(path: "../MagicKit"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2")
    ],
    targets: [
        .target(
            name: "PluginBookControl",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources/PluginBookControl",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookControlTests",
            dependencies: ["PluginBookControl"],
            path: "Tests/PluginBookControlTests"
        )
    ]
)
