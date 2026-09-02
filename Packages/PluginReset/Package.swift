// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginReset",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginReset",
            targets: ["PluginReset"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginReset",
            dependencies: [
                "CisumUIComponents",
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ResetPluginTests",
            dependencies: ["PluginReset"],
            path: "Tests"
        )
    ]
)
