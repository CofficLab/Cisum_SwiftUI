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
        .package(path: "../CisumUIComponents")
    ],
    targets: [
        .target(
            name: "PluginThemeOcean",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeOceanPluginTests",
            dependencies: ["PluginThemeOcean"],
            path: "Tests"
        )
    ]
)
