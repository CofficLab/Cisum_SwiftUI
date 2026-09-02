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
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderScene")
    ],
    targets: [
        .target(
            name: "PluginAudioDemo",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderScene", package: "ProviderScene")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioDemoPluginTests",
            dependencies: ["PluginAudioDemo"],
            path: "Tests"
        )
    ]
)
