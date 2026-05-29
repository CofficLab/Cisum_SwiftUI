// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioWidgetControl",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioWidgetControl",
            targets: ["PluginAudioWidgetControl"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/CisumUI"),
        .package(path: "../PluginAudio"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2"),
    ],
    targets: [
        .target(
            name: "PluginAudioWidgetControl",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources/PluginAudioWidgetControl",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioWidgetControlTests",
            dependencies: ["PluginAudioWidgetControl"],
            path: "Tests/PluginAudioWidgetControlTests"
        )
    ]
)
