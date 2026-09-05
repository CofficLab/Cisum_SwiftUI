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
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../ProviderScene"),
        .package(path: "../ProviderPlayback")
    ],
    targets: [
        .target(
            name: "PluginBookPlayMode",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderScene", package: "ProviderScene"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookPlayModePluginTests",
            dependencies: ["PluginBookPlayMode"],
            path: "Tests"
        )
    ]
)
