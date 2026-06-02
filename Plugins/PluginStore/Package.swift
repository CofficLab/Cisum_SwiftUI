// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginStore",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginStore",
            targets: ["PluginStore"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../PluginAudio"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "PluginStore",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "PluginAudio", package: "PluginAudio"),
                .product(name: "MagicAlert", package: "MagicAlert")
            ],
            path: "Sources/PluginStore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginStoreTests",
            dependencies: ["PluginStore"],
            path: "Tests"
        )
    ]
)
