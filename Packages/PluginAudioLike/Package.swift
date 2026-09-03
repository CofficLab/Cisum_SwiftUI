// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioLike",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioLike",
            targets: ["PluginAudioLike"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../KernelCore"),
        .package(path: "../ProviderScene")
    ],
    targets: [
        .target(
            name: "PluginAudioLike",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderScene", package: "ProviderScene")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioLikePluginTests",
            dependencies: ["PluginAudioLike"],
            path: "Tests"
        )
    ]
)
