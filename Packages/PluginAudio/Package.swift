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
            name: "AudioLibraryCore",
            targets: ["AudioLibraryCore"]
        ),
        .library(
            name: "PluginAudio",
            targets: ["PluginAudio"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../PluginAudioLike"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "AudioLibraryCore",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
                .product(name: "AudioLikeCore", package: "PluginAudioLike")
            ],
            path: ".",
            sources: [
                "Sources/Events",
                "Sources/Extensions",
                "Sources/Models",
                "Sources/Services"
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "PluginAudio",
            dependencies: [
                "AudioLibraryCore",
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
                .product(name: "AudioLikeCore", package: "PluginAudioLike"),
            ],
            path: ".",
            sources: [
                "Sources/AudioPlugin.swift",
                "Sources/CoreExports.swift",
                "Sources/Observers",
                "Sources/ViewModels",
                "Sources/Views"
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioPluginTests",
            dependencies: [
                "PluginAudio",
                "AudioLibraryCore"
            ],
            path: "Tests"
        )
    ]
)
