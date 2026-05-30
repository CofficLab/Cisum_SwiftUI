// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookProgress",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookProgress",
            targets: ["PluginBookProgress"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../PluginBook"),
        .package(path: "../PluginBookScene"),
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "PluginBookProgress",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginBook", package: "PluginBook"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources/PluginBookProgress",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginBookProgressTests",
            dependencies: ["PluginBookProgress"],
            path: "Tests/PluginBookProgressTests"
        )
    ]
)
