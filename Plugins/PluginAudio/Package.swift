// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudio",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudio",
            targets: ["PluginAudio"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../PluginAudioLike"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "PluginAudio",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "PluginAudioLike", package: "PluginAudioLike"),
                .product(name: "MagicAlert", package: "MagicAlert")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioTests",
            dependencies: ["PluginAudio"],
            path: "Tests"
        )
    ]
)
