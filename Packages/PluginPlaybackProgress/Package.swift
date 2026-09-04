// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPlaybackProgress",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PluginPlaybackProgress",
            targets: ["PluginPlaybackProgress"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(name: "KernelCore", path: "../KernelCore"),
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
    ],
    targets: [
        .target(
            name: "PluginPlaybackProgress",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
            ],
            path: ".",
            sources: ["Sources"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
