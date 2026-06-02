// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeCisum",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeCisum",
            targets: ["PluginThemeCisum"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeCisum",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources/PluginThemeCisum",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeCisumTests",
            dependencies: ["PluginThemeCisum"],
            path: "Tests"
        )
    ]
)
