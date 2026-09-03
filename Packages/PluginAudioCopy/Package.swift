// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PluginAudioCopy",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PluginAudioCopy",
            targets: ["PluginAudioCopy"]
        ),
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginStore"),
    ],
    targets: [
        .target(
            name: "PluginAudioCopy",
            dependencies: [
                "CisumUIComponents",
                "PluginAudio",
                "PluginStore",
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "AudioCopyPluginTests",
            dependencies: ["PluginAudioCopy"],
            path: "Tests"
        ),
    ]
)
