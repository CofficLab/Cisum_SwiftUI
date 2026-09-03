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
        .package(path: "../CisumUIComponents")
    ],
    targets: [
        .target(
            name: "PluginThemeMono",
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
            name: "ThemeMonoPluginTests",
            dependencies: ["PluginThemeMono"],
            path: "Tests"
        )
    ]
)
