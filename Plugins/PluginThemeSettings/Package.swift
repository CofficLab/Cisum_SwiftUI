// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeSettings",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeSettings",
            targets: ["PluginThemeSettings"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeSettings",
            dependencies: ["CisumUI"],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeSettingsTests",
            dependencies: ["PluginThemeSettings"],
            path: "Tests"
        )
    ]
)
