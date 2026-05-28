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
        .package(path: "../MagicKit")
    ],
    targets: [
        .target(
            name: "PluginMigrate",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginMigrate",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginMigrateTests",
            dependencies: ["PluginMigrate"],
            path: "Tests/PluginMigrateTests"
        )
    ]
)
