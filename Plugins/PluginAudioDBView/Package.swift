// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioDBView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioDBView",
            targets: ["PluginAudioDBView"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../../Packages/MagicPlayMan"),
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
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioDBViewTests",
            dependencies: ["PluginAudioDBView"],
            path: "Tests"
        )
    ]
)
