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
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../PluginAudio"),
        .package(path: "../MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "PluginAudioWidgetControl",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioWidgetControlPluginTests",
            dependencies: ["PluginAudioWidgetControl"],
            path: "Tests"
        )
    ]
)
