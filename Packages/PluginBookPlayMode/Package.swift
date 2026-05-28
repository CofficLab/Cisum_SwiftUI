// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookPlayMode",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookPlayMode",
            targets: ["PluginBookPlayMode"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.2")
    ],
    targets: [
        .target(
            name: "PluginBookPlayMode",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources/PluginBookPlayMode",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookPlayModeTests",
            dependencies: ["PluginBookPlayMode"],
            path: "Tests/PluginBookPlayModeTests"
        )
    ]
)
