// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioJob",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioJob",
            targets: ["PluginAudioJob"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/CisumUI"),
        .package(path: "../PluginAudio"),
        .package(path: "../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "PluginAudioJob",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginAudioJob",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioJobTests",
            dependencies: ["PluginAudioJob"],
            path: "Tests/PluginAudioJobTests"
        )
    ]
)
