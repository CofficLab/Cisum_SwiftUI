// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BookPlugin",
            targets: ["BookPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "BookPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookPluginTests",
            dependencies: ["BookPlugin"],
            path: "Tests"
        )
    ]
)
