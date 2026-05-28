// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeAurora",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeAurora",
            targets: ["PluginThemeAurora"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeAurora",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources/PluginThemeAurora",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeAuroraTests",
            dependencies: ["PluginThemeAurora"],
            path: "Tests/PluginThemeAuroraTests"
        )
    ]
)
