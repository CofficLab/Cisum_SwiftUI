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
            name: "PluginAudioLike",
            targets: ["PluginAudioLike"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/CisumUI"),
        .package(path: "../PluginAudioScene"),
        .package(path: "../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "PluginAudioLike",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginAudioScene", package: "PluginAudioScene"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources/PluginAudioLike",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioLikeTests",
            dependencies: ["PluginAudioLike"],
            path: "Tests/PluginAudioLikeTests"
        )
    ]
)
