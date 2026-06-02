// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeMidnight",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeMidnight",
            targets: ["PluginThemeMidnight"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeMidnight",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Theme-Midnight.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginThemeMidnightTests",
            dependencies: ["PluginThemeMidnight"],
            path: "Tests"
        )
    ]
)
