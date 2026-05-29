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
        .package(path: "../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeSunset",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources/PluginThemeSunset",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeSunsetTests",
            dependencies: ["PluginThemeSunset"],
            path: "Tests/PluginThemeSunsetTests"
        )
    ]
)
