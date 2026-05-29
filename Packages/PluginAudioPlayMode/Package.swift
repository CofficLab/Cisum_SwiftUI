// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioPlayMode",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioPlayMode",
            targets: ["PluginAudioPlayMode"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "PluginAudioPlayMode",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources/PluginAudioPlayMode",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioPlayModeTests",
            dependencies: ["PluginAudioPlayMode"],
            path: "Tests/PluginAudioPlayModeTests"
        )
    ]
)
