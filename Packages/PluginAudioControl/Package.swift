// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioControl",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioControl",
            targets: ["PluginAudioControl"]
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
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginAudioControl",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderScene", package: "ProviderScene"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginAudioControlTests",
            dependencies: ["PluginAudioControl"],
            path: "Tests"
        )
    ]
)
