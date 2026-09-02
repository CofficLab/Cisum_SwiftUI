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
        .package(path: "../CisumUI"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginStore"),
    ],
    targets: [
        .target(
            name: "PluginAudioCopy",
            dependencies: [
                "CisumUI",
                "PluginAudio",
                "PluginStore",
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "AudioCopyPluginTests",
            dependencies: ["PluginAudioCopy"],
            path: "Tests"
        ),
    ]
)
