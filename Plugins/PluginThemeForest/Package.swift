// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeForest",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeForest",
            targets: ["PluginThemeForest"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeForest",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources/PluginThemeForest",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeForestTests",
            dependencies: ["PluginThemeForest"],
            path: "Tests/PluginThemeForestTests"
        )
    ]
)
