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
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeStudioBlue",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Theme-StudioBlue.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginThemeStudioBlueTests",
            dependencies: ["PluginThemeStudioBlue"],
            path: "Tests"
        )
    ]
)
