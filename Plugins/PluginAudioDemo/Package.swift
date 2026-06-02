// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioDemo",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioDemo",
            targets: ["PluginAudioDemo"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../PluginAudioScene")
    ],
    targets: [
        .target(
            name: "PluginAudioDemo",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene")
            ],
            path: "Sources/PluginAudioDemo",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioDemoTests",
            dependencies: ["PluginAudioDemo"],
            path: "Tests"
        )
    ]
)
