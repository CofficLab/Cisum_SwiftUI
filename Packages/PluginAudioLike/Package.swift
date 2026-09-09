// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioLike",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioLikeCore",
            targets: ["AudioLikeCore"]
        ),
        .library(
            name: "PluginAudioLike",
            targets: ["PluginAudioLike"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../ProviderScene"),
        .package(path: "../ProviderPlayback")
    ],
    targets: [
        .target(
            name: "AudioLikeCore",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents")
            ],
            path: ".",
            sources: [
                "Sources/Models/AudioLikeModel.swift",
                "Sources/Services/AudioLikeRepo.swift"
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "PluginAudioLike",
            dependencies: [
                "AudioLikeCore",
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderScene", package: "ProviderScene"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback")
            ],
            path: ".",
            sources: [
                "Sources/AudioLikePlugin.swift",
                "Sources/Capabilities",
                "Sources/Events",
                "Sources/Models/AudioLikePluginInfo.swift",
                "Sources/Observers",
                "Sources/ViewModels",
                "Sources/Views"
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioLikePluginTests",
            dependencies: [
                "PluginAudioLike",
                "AudioLikeCore"
            ],
            path: "Tests"
        )
    ]
)
