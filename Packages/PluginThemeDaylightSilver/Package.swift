// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeDaylightSilver",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeDaylightSilver",
            targets: ["PluginThemeDaylightSilver"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI")
    ],
    targets: [
        .target(
            name: "PluginThemeDaylightSilver",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeDaylightSilverPluginTests",
            dependencies: ["PluginThemeDaylightSilver"],
            path: "Tests"
        )
    ]
)
