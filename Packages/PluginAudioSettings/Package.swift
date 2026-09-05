// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioSettings",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioSettings",
            targets: ["PluginAudioSettings"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../PluginAudio")
    ],
    targets: [
        .target(
            name: "PluginAudioSettings",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                "CisumUIComponents",
                "KernelCore",
                "ProviderDocsView",
                .product(name: "PluginAudio", package: "PluginAudio")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioSettingsPluginTests",
            dependencies: ["PluginAudioSettings"],
            path: "Tests"
        )
    ]
)
