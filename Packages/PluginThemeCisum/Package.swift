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
        .package(path: "../CisumUIComponents")
    ],
    targets: [
        .target(
            name: "PluginThemeCisum",
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
            name: "ThemeCisumPluginTests",
            dependencies: ["PluginThemeCisum"],
            path: "Tests"
        )
    ]
)
