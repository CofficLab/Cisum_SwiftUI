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
        .package(path: "../CisumUI"),
        .package(path: "../CisumKernel"),
        .package(path: "../PluginAudioLike"),
    ],
    targets: [
        .target(
            name: "PluginAudio",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "PluginAudioLike", package: "PluginAudioLike"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioPluginTests",
            dependencies: ["PluginAudio"],
            path: "Tests"
        )
    ]
)
