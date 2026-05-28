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
    targets: [
        .target(
            name: "PluginAudioDemo",
            path: "Sources/PluginAudioDemo",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioDemoTests",
            dependencies: ["PluginAudioDemo"],
            path: "Tests/PluginAudioDemoTests"
        )
    ]
)
