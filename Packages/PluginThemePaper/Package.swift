// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemePaper",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemePaper",
            targets: ["PluginThemePaper"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemePaper",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources/PluginThemePaper",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemePaperTests",
            dependencies: ["PluginThemePaper"],
            path: "Tests/PluginThemePaperTests"
        )
    ]
)
