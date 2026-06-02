// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLikeButton",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginLikeButton",
            targets: ["PluginLikeButton"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "PluginLikeButton",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources/PluginLikeButton",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginLikeButtonTests",
            dependencies: ["PluginLikeButton"],
            path: "Tests"
        )
    ]
)
