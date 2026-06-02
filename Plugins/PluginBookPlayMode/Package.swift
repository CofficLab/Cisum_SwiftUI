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
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../PluginBookScene"),
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "PluginBookPlayMode",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookPlayModeTests",
            dependencies: ["PluginBookPlayMode"],
            path: "Tests"
        )
    ]
)
