// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioDBView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioDBView",
            targets: ["PluginAudioDBView"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../CisumKernel"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../ProviderScene"),
    ],
    targets: [
        .target(
            name: "PluginAudioDBView",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderScene", package: "ProviderScene"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioDBViewPluginTests",
            dependencies: ["PluginAudioDBView"],
            path: "Tests"
        )
    ]
)
