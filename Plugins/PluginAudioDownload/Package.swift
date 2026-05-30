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
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "PluginAudioDownload",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources/PluginAudioDownload",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioDownloadTests",
            dependencies: ["PluginAudioDownload"],
            path: "Tests/PluginAudioDownloadTests"
        )
    ]
)
