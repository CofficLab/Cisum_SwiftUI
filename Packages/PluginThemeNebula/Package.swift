// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeNebula",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeNebula",
            targets: ["PluginThemeNebula"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents")
    ],
    targets: [
        .target(
            name: "PluginThemeNebula",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeNebulaPluginTests",
            dependencies: ["PluginThemeNebula"],
            path: "Tests"
        )
    ]
)
