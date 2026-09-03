// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookProgress",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookProgress",
            targets: ["PluginBookProgress"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginBook"),
        .package(path: "../PluginBookScene"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderScene")
    ],
    targets: [
        .target(
            name: "PluginBookProgress",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginBook", package: "PluginBook"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderScene", package: "ProviderScene")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookProgressPluginTests",
            dependencies: [
                "PluginBookProgress",
                .product(name: "PluginBook", package: "PluginBook")
            ],
            path: "Tests"
        )
    ]
)
