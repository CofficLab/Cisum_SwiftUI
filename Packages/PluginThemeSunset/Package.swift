// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeSunset",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeSunset",
            targets: ["PluginThemeSunset"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeSunset",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeSunsetPluginTests",
            dependencies: ["PluginThemeSunset"],
            path: "Tests"
        )
    ]
)
