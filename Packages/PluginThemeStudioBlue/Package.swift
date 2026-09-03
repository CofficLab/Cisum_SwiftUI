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
        .package(path: "../CisumUIComponents")
    ],
    targets: [
        .target(
            name: "PluginThemeStudioBlue",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeStudioBluePluginTests",
            dependencies: ["PluginThemeStudioBlue"],
            path: "Tests"
        )
    ]
)
