// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeStudioBlue",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeStudioBlue",
            targets: ["PluginThemeStudioBlue"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeStudioBlue",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources/PluginThemeStudioBlue",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeStudioBlueTests",
            dependencies: ["PluginThemeStudioBlue"],
            path: "Tests/PluginThemeStudioBlueTests"
        )
    ]
)
