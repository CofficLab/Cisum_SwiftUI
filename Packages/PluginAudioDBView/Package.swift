// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioDBView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PluginAudioDBView",
            targets: ["PluginAudioDBView"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../MagicKit"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "PluginAudioDBView",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "MagicAlert", package: "MagicAlert")
            ],
            path: "Sources/PluginAudioDBView",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioDBViewTests",
            dependencies: ["PluginAudioDBView"],
            path: "Tests/PluginAudioDBViewTests"
        )
    ]
)
