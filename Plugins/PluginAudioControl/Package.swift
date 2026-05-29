// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioControl",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PluginAudioControl",
            targets: ["PluginAudioControl"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/CisumUI"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2"),
    ],
    targets: [
        .target(
            name: "PluginAudioControl",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources/PluginAudioControl",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioControlTests",
            dependencies: ["PluginAudioControl"],
            path: "Tests/PluginAudioControlTests"
        )
    ]
)
