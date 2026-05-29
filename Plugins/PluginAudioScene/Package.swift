// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAudioScene",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAudioScene",
            targets: ["PluginAudioScene"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/CisumUI"),
        .package(path: "../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "PluginAudioScene",
            dependencies: [
                "CisumUI",
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginAudioScene",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginAudioSceneTests",
            dependencies: ["PluginAudioScene"],
            path: "Tests/PluginAudioSceneTests"
        )
    ]
)
