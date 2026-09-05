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
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../ProviderScene"),
        .package(path: "../ProviderPlayback")
    ],
    targets: [
        .target(
            name: "PluginAudioPlayMode",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderScene", package: "ProviderScene"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioPlayModePluginTests",
            dependencies: ["PluginAudioPlayMode"],
            path: "Tests"
        )
    ]
)
