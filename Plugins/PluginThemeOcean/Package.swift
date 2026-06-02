// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeOcean",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeOcean",
            targets: ["PluginThemeOcean"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeOcean",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Theme-Ocean.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginThemeOceanTests",
            dependencies: ["PluginThemeOcean"],
            path: "Tests"
        )
    ]
)
