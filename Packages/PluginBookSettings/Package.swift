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
        .package(path: "../KernelCore"),
        .package(path: "../PluginBook")
    ],
    targets: [
        .target(
            name: "PluginBookSettings",
            dependencies: [
                "CisumUIComponents",
                "KernelCore",
                .product(name: "PluginBook", package: "PluginBook")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookSettingsPluginTests",
            dependencies: ["PluginBookSettings"],
            path: "Tests"
        )
    ]
)
