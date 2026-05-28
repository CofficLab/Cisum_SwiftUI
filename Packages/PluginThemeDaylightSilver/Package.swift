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
            path: "Sources/PluginThemeDaylightSilver",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginThemeDaylightSilverTests",
            dependencies: ["PluginThemeDaylightSilver"],
            path: "Tests/PluginThemeDaylightSilverTests"
        )
    ]
)
