// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookLike",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookLike",
            targets: ["PluginBookLike"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../PluginBookScene"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "PluginBookLike",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "PluginBookScene", package: "PluginBookScene"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Book-Like.xcstrings")
            ]
        ),
        .testTarget(
            name: "PluginBookLikeTests",
            dependencies: ["PluginBookLike"],
            path: "Tests"
        )
    ]
)
