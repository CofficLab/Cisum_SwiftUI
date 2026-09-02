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
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "MigratePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI")
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
