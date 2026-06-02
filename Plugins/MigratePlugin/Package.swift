// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MigratePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MigratePlugin",
            targets: ["MigratePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "MigratePlugin",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "MigratePluginTests",
            dependencies: ["MigratePlugin"],
            path: "Tests"
        )
    ]
)
