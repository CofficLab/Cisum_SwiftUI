// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VideoPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VideoPlugin",
            targets: ["VideoPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "VideoPlugin",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "VideoPluginTests",
            dependencies: ["VideoPlugin"],
            path: "Tests"
        )
    ]
)
