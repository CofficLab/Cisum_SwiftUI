// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeMono",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeMono",
            targets: ["PluginThemeMono"]
        )
    ],
    dependencies: [
        .package(path: "../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeMono",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources/PluginThemeMono",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeMonoTests",
            dependencies: ["PluginThemeMono"],
            path: "Tests/PluginThemeMonoTests"
        )
    ]
)
