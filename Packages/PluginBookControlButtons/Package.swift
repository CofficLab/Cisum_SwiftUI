// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookControlButtons",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookControlButtons",
            targets: ["PluginBookControlButtons"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginBook"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../ProviderScene"),
        .package(path: "../ProviderPlayback"),
        .package(path: "../ProviderRootView"),
    ],
    targets: [
        .target(
            name: "PluginBookControlButtons",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginBook", package: "PluginBook"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderScene", package: "ProviderScene"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                .product(name: "ProviderRootView", package: "ProviderRootView"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookControlButtonsPluginTests",
            dependencies: ["PluginBookControlButtons"],
            path: "Tests"
        )
    ]
)
