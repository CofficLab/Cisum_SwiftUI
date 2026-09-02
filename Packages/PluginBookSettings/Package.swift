// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookSettings",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookSettings",
            targets: ["PluginBookSettings"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../PluginBook")
    ],
    targets: [
        .target(
            name: "PluginBookSettings",
            dependencies: [
                "CisumUIComponents",
                .product(name: "PluginBook", package: "PluginBook")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookSettingsPluginTests",
            dependencies: ["PluginBookSettings"],
            path: "Tests"
        )
    ]
)
