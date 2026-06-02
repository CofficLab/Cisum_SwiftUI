// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginWelcome",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginWelcome",
            targets: ["PluginWelcome"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "PluginWelcome",
            dependencies: [
                "CisumUI",
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginWelcome",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginWelcomeTests",
            dependencies: ["PluginWelcome"],
            path: "Tests"
        )
    ]
)
