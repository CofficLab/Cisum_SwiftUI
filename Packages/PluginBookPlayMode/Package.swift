// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookPlayMode",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookPlayMode",
            targets: ["PluginBookPlayMode"]
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
            name: "PluginBookPlayMode",
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
            name: "BookPlayModePluginTests",
            dependencies: ["PluginBookPlayMode"],
            path: "Tests"
        )
    ]
)
