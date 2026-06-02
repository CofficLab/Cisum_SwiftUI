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
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../PluginBookScene"),
        .package(path: "../PluginBook"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "PluginBookControl",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "PluginBook", package: "PluginBook"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Book-Control.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginBookControlTests",
            dependencies: ["PluginBookControl"],
            path: "Tests"
        )
    ]
)
