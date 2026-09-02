// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioScene",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioScene",
            targets: ["PluginAudioScene"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderScene"),
    ],
    targets: [
        .target(
            name: "PluginAudioScene",
            dependencies: [
                "CisumUIComponents",
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderScene", package: "ProviderScene"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioScenePluginTests",
            dependencies: ["PluginAudioScene"],
            path: "Tests"
        )
    ]
)
