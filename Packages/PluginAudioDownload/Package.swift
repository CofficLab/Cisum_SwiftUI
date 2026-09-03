// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioDownload",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioDownload",
            targets: ["PluginAudioDownload"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderScene")
    ],
    targets: [
        .target(
            name: "PluginAudioDownload",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderScene", package: "ProviderScene")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioDownloadPluginTests",
            dependencies: ["PluginAudioDownload"],
            path: "Tests"
        )
    ]
)
