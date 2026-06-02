// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginVideo",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginVideo",
            targets: ["PluginVideo"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "PluginVideo",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginVideo",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginVideoTests",
            dependencies: ["PluginVideo"],
            path: "Tests"
        )
    ]
)
