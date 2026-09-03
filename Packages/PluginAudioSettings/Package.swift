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
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(path: "../PluginAudio")
    ],
    targets: [
        .target(
            name: "PluginAudioSettings",
            dependencies: [
                "CisumUIComponents",
                "KernelCore",
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
