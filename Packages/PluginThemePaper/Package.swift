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
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemePaperPluginTests",
            dependencies: ["PluginThemePaper"],
            path: "Tests"
        )
    ]
)
