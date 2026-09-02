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
        .package(path: "../CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeForest",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeForestPluginTests",
            dependencies: ["PluginThemeForest"],
            path: "Tests"
        )
    ]
)
