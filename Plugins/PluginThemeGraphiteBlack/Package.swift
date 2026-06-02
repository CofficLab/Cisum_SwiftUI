// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeGraphiteBlack",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeGraphiteBlack",
            targets: ["PluginThemeGraphiteBlack"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeGraphiteBlack",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginThemeGraphiteBlackTests",
            dependencies: ["PluginThemeGraphiteBlack"],
            path: "Tests"
        )
    ]
)
