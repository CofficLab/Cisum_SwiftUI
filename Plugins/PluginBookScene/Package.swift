// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookScene",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookScene",
            targets: ["PluginBookScene"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "PluginBookScene",
            dependencies: [
                "CisumUI",
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginBookScene",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookSceneTests",
            dependencies: ["PluginBookScene"],
            path: "Tests/PluginBookSceneTests"
        )
    ]
)
