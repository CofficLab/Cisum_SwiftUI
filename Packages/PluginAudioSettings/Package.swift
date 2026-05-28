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
        .package(path: "../CisumUI"),
        .package(path: "../MagicKit")
    ],
    targets: [
        .target(
            name: "PluginAudioSettings",
            dependencies: [
                "CisumUI",
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginAudioSettings",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioSettingsTests",
            dependencies: ["PluginAudioSettings"],
            path: "Tests/PluginAudioSettingsTests"
        )
    ]
)
