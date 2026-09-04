// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPlaybackHero",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PluginPlaybackHero",
            targets: ["PluginPlaybackHero"]
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
            name: "PluginPlaybackHero",
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
