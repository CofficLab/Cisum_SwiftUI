// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginMigrate",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginMigrate",
            targets: ["PluginMigrate"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUIComponents")
    ],
    targets: [
        .target(
            name: "PluginMigrate",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "MigratePluginTests",
            dependencies: ["PluginMigrate"],
            path: "Tests"
        )
    ]
)
