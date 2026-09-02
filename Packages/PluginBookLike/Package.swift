// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookLike",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookLike",
            targets: ["PluginBookLike"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginBookScene"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderScene")
    ],
    targets: [
        .target(
            name: "PluginBookLike",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderScene", package: "ProviderScene")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookLikePluginTests",
            dependencies: ["PluginBookLike"],
            path: "Tests"
        )
    ]
)
