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
        .package(path: "../CisumUI"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../PluginAudioLike"),
        .package(path: "../MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "PluginAudioProgress",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "PluginAudioLike", package: "PluginAudioLike"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioProgressPluginTests",
            dependencies: ["PluginAudioProgress"],
            path: "Tests"
        )
    ]
)
