// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioProgress",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioProgress",
            targets: ["PluginAudioProgress"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../PluginAudioLike"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderScene"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginAudioProgress",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "PluginAudioLike", package: "PluginAudioLike"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderScene", package: "ProviderScene"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioProgressPluginTests",
            dependencies: ["PluginAudioProgress"],
            path: "Tests"
        )
    ]
)
