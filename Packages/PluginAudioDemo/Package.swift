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
        .package(path: "../KernelCore"),
        .package(path: "../ProviderScene")
    ],
    targets: [
        .target(
            name: "PluginAudioDemo",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderScene", package: "ProviderScene")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioDemoPluginTests",
            dependencies: ["PluginAudioDemo"],
            path: "Tests"
        )
    ]
)
