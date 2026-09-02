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
        .package(path: "../PluginBook"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginBookControl",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "PluginBook", package: "PluginBook"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookControlPluginTests",
            dependencies: ["PluginBookControl"],
            path: "Tests"
        )
    ]
)
