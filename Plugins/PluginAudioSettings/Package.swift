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
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../PluginAudio")
    ],
    targets: [
        .target(
            name: "PluginAudioSettings",
            dependencies: [
                "CisumUI",
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "PluginAudio", package: "PluginAudio")
            ],
            path: "Sources",
            resources: [
                .process("Audio-Settings.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginAudioSettingsTests",
            dependencies: ["PluginAudioSettings"],
            path: "Tests"
        )
    ]
)
