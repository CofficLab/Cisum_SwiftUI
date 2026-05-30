// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PluginAudioCopy",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "PluginAudioCopy",
            targets: ["PluginAudioCopy"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginStore"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "PluginAudioCopy",
            dependencies: [
                "CisumUI",
                "MagicKit",
                "PluginAudio",
                "PluginStore",
                "MagicAlert",
            ],
            resources: [
                .process("Audio-Copy-macOS.xcstrings"),
            ]
        ),
        .testTarget(
            name: "PluginAudioCopyTests",
            dependencies: ["PluginAudioCopy"]
        ),
    ]
)
