// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioProgress",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PluginAudioProgress",
            targets: ["PluginAudioProgress"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioLike"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "PluginAudioProgress",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioLike", package: "PluginAudioLike"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "MagicAlert", package: "MagicAlert")
            ],
            path: "Sources/PluginAudioProgress",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioProgressTests",
            dependencies: ["PluginAudioProgress"],
            path: "Tests/PluginAudioProgressTests"
        )
    ]
)
