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
        .package(path: "../CisumUI"),
        .package(path: "../PluginAudio"),
    ],
    targets: [
        .target(
            name: "PluginAudioJob",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudio", package: "PluginAudio"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioJobPluginTests",
            dependencies: ["PluginAudioJob"],
            path: "Tests"
        )
    ]
)
